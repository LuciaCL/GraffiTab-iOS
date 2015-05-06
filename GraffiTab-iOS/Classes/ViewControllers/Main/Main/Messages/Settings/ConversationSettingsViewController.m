//
//  ConversationSettingsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 13/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ConversationSettingsViewController.h"
#import "AddConversationUsersViewController.h"
#import "UIActionSheet+Blocks.h"
#import "ImageCropViewController.h"

@interface ConversationSettingsViewController () {
    
    UIImagePickerController *galleryPicker;
    BOOL editing;
}

@property (nonatomic, weak) UITextField *conversationTitle;
@property (nonatomic, weak) UIImageView *conversationImage;

- (IBAction)onClickEdit:(id)sender;

@end

@implementation ConversationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
}

- (IBAction)onClickEdit:(id)sender {
    [UIActionSheet showInView:self.view
                    withTitle:@"What would you like to do?"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"Change group image", @"Edit group name"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if (buttonIndex == 0)
                             [self onClickChangeImage];
                         else if (buttonIndex == 1)
                             [self onClickDone];
                     }];
}

- (void)onClickChangeImage {
    [UIActionSheet showInView:self.view
                    withTitle:@"Choose source"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"Take new", @"Choose from Library", @"Remove group image"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if (buttonIndex == 0)
                             [self doTakeNew];
                         else if (buttonIndex == 1)
                             [self doChooseFromGallery];
                         else if (buttonIndex == 2) {
                             [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to remove this group image?" yesTitle:@"Yes" noTitle:@"No" yesBlock:^{
                                 [self changeImage:nil];
                             } noBlock:^{}];
                         }
                     }];
}

- (void)onClickDone {
    editing = !editing;
    
    if (editing)
        [_conversationTitle becomeFirstResponder];
    else {
        [_conversationTitle resignFirstResponder];
        [self changeName];
    }
    
    [self refreshEditButton];
}

- (void)refreshEditButton {
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onClickEdit:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickDone)];
    
    [self.navigationItem setRightBarButtonItem:editing ? done : edit animated:YES];
}

- (void)changeName {
    if (![self.conversation.name isEqualToString:_conversationTitle.text]) {
        if (_conversationTitle.text.length > 0) {
            [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
            
            [GTConversationManager editConversationTitleWithId:self.conversation.conversationId text:_conversationTitle.text successBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                GTConversation *c = response.object;
                self.conversation.name = c.name;
                
                [self.tableView reloadData];
            } failureBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                if (response.reason == AUTHORIZATION_NEEDED) {
                    [Utils logoutUserAndShowLoginController];
                    [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
                }
                else
                    [Utils showMessage:APP_NAME message:response.message];
            }];
        }
    }
}

- (void)changeImage:(UIImage *)image {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    [GTConversationManager editConversationImageWithConversationId:self.conversation.conversationId image:image successBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        GTConversation *c = response.object;
        self.conversation.imageId = c.imageId;
        
        [self.tableView reloadData];
    } failureBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

#pragma mark - Image picking

- (void)doTakeNew {
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
        [Utils showMessage:APP_NAME message:@"No camera app was found on this device."];
    else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:
                             (NSString *) kUTTypeImage,
                             nil];
        
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void)doChooseFromGallery {
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] )
        [Utils showMessage:APP_NAME message:@"No gallery app was found on this device."];
    else {
        galleryPicker = [[UIImagePickerController alloc] init];
        galleryPicker.delegate = self;
        galleryPicker.allowsEditing = NO;
        galleryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        galleryPicker.mediaTypes = [NSArray arrayWithObjects:
                                    (NSString *) kUTTypeImage,
                                    nil];
        
        [self presentViewController:galleryPicker animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SEGUE_ADD_PEOPLE"]) {
        AddConversationUsersViewController *vc = segue.destinationViewController;
        vc.conversation = self.conversation;
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return self.conversation.members.count + 1;
        case 2:
            return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
            
            _conversationImage = (UIImageView *)[cell viewWithTag:1];
            _conversationImage.layer.cornerRadius = _conversationImage.frame.size.width / 2;
            _conversationImage.layer.borderWidth = 2;
            _conversationImage.layer.borderColor = UIColorFromRGB(0x77c7ed).CGColor;
            _conversationImage.userInteractionEnabled = YES;
            
            UIImageView *editView = (UIImageView *)[cell viewWithTag:3];
            editView.center = _conversationImage.center;
            editView.image = [editView.image imageWithTint:UIColorFromRGB(0x77c7ed)];
            
            // Load avatar.
            __weak typeof(self) weakSelf = self;
            
            if (self.conversation.imageId > 0) {
                editView.hidden = YES;
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetConversationImage:self.conversation.imageId]]];
                request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                
                _conversationImage.image = nil;
                [_conversationImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [UIView transitionWithView:weakSelf.conversationImage
                                      duration:0.5f
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        weakSelf.conversationImage.image = image;
                                    } completion:nil];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    weakSelf.conversationImage.image = nil;
                }];
            }
            else {
                _conversationImage.image = nil;
                
                editView.hidden = NO;
            }
            
            [_conversationImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickChangeImage)]];
            
            _conversationTitle = (UITextField *)[cell viewWithTag:2];
            _conversationTitle.text = self.conversation.name ? self.conversation.name : @"Untitled";
            _conversationTitle.delegate = self;
            _conversationTitle.layer.shadowOpacity = 1.0;
            _conversationTitle.layer.shadowRadius = 0.0;
            _conversationTitle.layer.shadowColor = [UIColor blackColor].CGColor;
            _conversationTitle.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            
            break;
        }
        case 1: {
            if (indexPath.row >= self.conversation.members.count) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddPeopleCell"];
                
                cell.imageView.contentMode = UIViewContentModeCenter;
                cell.textLabel.textColor = UIColorFromRGB(COLOR_MAIN);
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
                
                cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                
                GTPerson *p = self.conversation.members[indexPath.row];
                cell.textLabel.text = p.fullName;
                cell.detailTextLabel.text = p.mentionUsername;
                
                // Load avatar.
                __weak typeof(UITableViewCell *) weakSelf = cell;
                
                if (p.avatarId > 0) {
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:p.avatarId]]];
                    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                    
                    cell.imageView.image = nil;
                    [cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        weakSelf.imageView.image = image;
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        weakSelf.imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
                    }];
                }
                else
                    cell.imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
            }
            
            break;
        }
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LeaveCell"];
            cell.textLabel.textColor = [UIColor redColor];
            cell.imageView.contentMode = UIViewContentModeCenter;
            
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 167;
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont systemFontOfSize:14];
        headerLabel.frame = CGRectMake(10, 5, 200, 25);
        headerLabel.textColor = UIColorFromRGB(COLOR_MAIN);
        headerLabel.text = @"MEMBERS";
        
        [customView addSubview:headerLabel];
        
        return customView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to leave this group?" yesTitle:@"Yes" noTitle:@"No" yesBlock:^{
            [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
            
            [GTConversationManager leaveConversation:self.conversation.conversationId successBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            } failureBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                if (response.reason == AUTHORIZATION_NEEDED) {
                    [Utils logoutUserAndShowLoginController];
                    [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
                }
                else
                    [Utils showMessage:APP_NAME message:response.message];
            }];
        } noBlock:^{}];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == self.conversation.members.count)
            [self performSegueWithIdentifier:@"SEGUE_ADD_PEOPLE" sender:nil];
        else
            [ViewControllerUtils showUserProfile:self.conversation.members[indexPath.row] fromViewController:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    [self changeName];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    editing = YES;
    
    [self refreshEditButton];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    editing = NO;
    
    [self refreshEditButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *i = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
        UINavigationController *cropperNavigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"ImageCropViewController"];
        ImageCropViewController *cropper = cropperNavigation.viewControllers[0];
        
        cropper.checkBounds = YES;
        cropper.rotateEnabled = YES;
        cropper.doneCallback = ^(UIImage *editedImage, BOOL canceled) {
            [cropperNavigation dismissViewControllerAnimated:YES completion:^{
                if (!canceled)
                    [self changeImage:editedImage];
            }];
        };
        
        cropper.sourceImage = i;
        cropper.previewImage = i;
        
        [self presentViewController:cropperNavigation animated:YES completion:NULL];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            int size = 300;
            cropper.cropRect = CGRectMake(self.view.frame.size.width / 2 - size / 2, (self.view.frame.size.height - (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT)) / 2 - size / 2, size, size);
            [cropper reset:YES];
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    picker = nil;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Group Settings";
}

- (void)setupTableView {
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
}

@end
