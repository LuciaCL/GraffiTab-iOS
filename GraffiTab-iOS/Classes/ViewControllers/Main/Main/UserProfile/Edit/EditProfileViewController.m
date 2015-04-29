//
//  EditProfileViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "EditProfileViewController.h"
#import "FXBlurView.h"
#import "UIActionSheet+Blocks.h"
#import "EXPhotoViewer.h"
#import "UIWindow+PazLabs.h"
#import "EditAvatarTask.h"
#import "EditCoverTask.h"
#import "ImageCropViewController.h"
#import "EditTextFieldViewController.h"
#import "EditTextViewViewController.h"
#import "EditProfileTask.h"

#define IMAGE_PICKER_MODE_AVATAR 0
#define IMAGE_PICKER_MODE_COVER 1

@interface EditProfileViewController () {
    
    IBOutlet UIImageView *avatarImage;
    IBOutlet UIImageView *coverImage;
    
    IBOutlet UILabel *firstNameLabel;
    IBOutlet UILabel *lastNameLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UILabel *aboutLabel;
    IBOutlet UILabel *websiteLabel;
    
    int imagePickerMode;
    Person *user;
    UIImage *defaultBlurredImage;
    UIImagePickerController *galleryPicker;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    user = [Settings getInstance].user;
    
    [self setupTopBar];
    [self setupDefaultImage];
    [self setupImageViews];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSave:(id)sender {
    NSString *fn = firstNameLabel.text;
    NSString *ln = lastNameLabel.text;
    NSString *em = emailLabel.text;
    NSString *ab = aboutLabel.text;
    NSString *we = websiteLabel.text;
    
    if ([InputValidator validateProfileEditInput:fn lastName:ln email:em about:ab website:we viewController:self.navigationController]) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        EditProfileTask *task = [EditProfileTask new];
        [task editProfileWithFirstName:fn lastName:ln email:em about:ab website:we successBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            user = [Settings getInstance].user;
            
            [self loadData];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showTitle:self.navigationController title:APP_NAME subTitle:@"Profile saved!" style:Success closeButtonTitle:@"OK" duration:0.0f];
        } failureBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == ALREADY_EXISTS)
                [[SCLAlertView new] showError:self.navigationController title:APP_NAME subTitle:@"This username or email have already been taken." closeButtonTitle:@"OK" duration:0.0f];
            else if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
}

- (void)onClickImage {
    NSArray *actions = @[@"View image", @"Change image", @"Remove image"];
    
    [UIActionSheet showInView:self.view
                    withTitle:@"What would you like to do?"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:actions
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"View image"]) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                 [self viewImage];
                             });
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Change image"]) {
                             NSMutableArray *actions = [NSMutableArray arrayWithObjects:@"Take new", @"Choose from Library", nil];
                             
                             if (FBSession.activeSession.state == FBSessionStateOpen && imagePickerMode == IMAGE_PICKER_MODE_AVATAR)
                                 [actions addObject:@"Import from Facebook"];
                             
                             [UIActionSheet showInView:self.view
                                             withTitle:@"Choose source"
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:actions
                                              tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                                  if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                                                      return;
                                                  
                                                  if (buttonIndex == 0)
                                                      [self doTakeNew];
                                                  else if (buttonIndex == 1)
                                                      [self doChooseFromGallery];
                                                  else if (buttonIndex == 2)
                                                      [self doImportFromFacebook];
                                              }];
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove image"]) {
                             [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to remove this image?" yesTitle:@"Yes" noTitle:@"No" yesBlock:^{
                                 [self changeImage:nil];
                             } noBlock:^{}];
                         }
                     }];
}

#pragma mark - Profile actions

- (void)viewImage {
    UIImageView *i;
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR)
        i = avatarImage;
    else if (imagePickerMode == IMAGE_PICKER_MODE_COVER)
        i = coverImage;
    
    [EXPhotoViewer showImageFrom:i rootViewController:self.navigationController];
}

- (void)changeImage:(UIImage *)image {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR) {
        EditAvatarTask *task = [EditAvatarTask new];
        [task editAvatarWithNewImage:image successBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            user = [Settings getInstance].user;
            
            [self loadAvatar];
        } failureBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else if (imagePickerMode == IMAGE_PICKER_MODE_COVER) {
        EditCoverTask *task = [EditCoverTask new];
        [task editCoverWithNewImage:image successBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            user = [Settings getInstance].user;
            
            [self loadCover];
        } failureBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
}

#pragma mark - Loading

- (void)loadData {
    [self setTextForCell:firstNameLabel text:user.firstname];
    [self setTextForCell:lastNameLabel text:user.lastname];
    [self setTextForCell:emailLabel text:user.email];
    [self setTextForCell:aboutLabel text:user.about];
    [self setTextForCell:websiteLabel text:user.website];
    
    [self loadAvatar];
    [self loadCover];
}

- (void)setTextForCell:(UILabel *)label text:(NSString *)text {
    label.text = text;
}

- (void)loadAvatar {
    __strong typeof(self) weakSelf = self;
    
    if (user.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:user.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [avatarImage setImageWithURLRequest:request placeholderImage:avatarImage.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:weakSelf->avatarImage
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf->avatarImage.image = image;
                            } completion:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf->avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

- (void)loadCover {
    __strong typeof(self) weakSelf = self;
    
    if (user.coverId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetCover:user.coverId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [coverImage setImageWithURLRequest:request placeholderImage:coverImage.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:weakSelf->coverImage
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf->coverImage.image = image;
                            } completion:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf->coverImage.image = weakSelf->defaultBlurredImage;
        }];
    }
    else {
        if (user.avatarId > 0) { // Darken + blur the user's avatar and use it as cover.
            // Download avatar.
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:user.avatarId]]];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            
            [coverImage setImageWithURLRequest:request placeholderImage:coverImage.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [weakSelf setDarkBlurredImageAsCover:image];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                weakSelf->coverImage.image = weakSelf->defaultBlurredImage;
            }];
        }
        else
            weakSelf->coverImage.image = defaultBlurredImage;
    }
}

- (void)setDarkBlurredImageAsCover:(UIImage *)i {
    UIImage *darken = [i colorizeImagWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
    UIImage *blur = [darken blurredImageWithRadius:40 iterations:2 tintColor:nil];
    
    [UIView transitionWithView:coverImage
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        coverImage.image = blur;
                    } completion:nil];
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

- (void)doImportFromFacebook {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
         if (!error) {
             NSString *userImageURL = [NSString stringWithFormat:APP_FACEBOOK_AVATAR_URL, [aUser objectID]];
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 // 1.2.1.2.1
                 NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]];
                 UIImage *image = [UIImage imageWithData:imageData];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[LoadingViewManager getInstance] removeLoadingView];
                     
                     [self changeImage:image];
                 });
             });
         }
         else
             [[LoadingViewManager getInstance] removeLoadingView];
     }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SEGUE_EDIT_TEXT_FIELD"]) {
        NSDictionary *senderDict = sender;
        
        EditTextFieldViewController *vc = segue.destinationViewController;
        vc.finishedEditingBlock = senderDict[@"sender"];
        vc.defaultValue = senderDict[@"default"];
        vc.canBeEmpty = [senderDict[@"canBeEmpty"] boolValue];
    }
    else if ([segue.identifier isEqualToString:@"SEGUE_EDIT_TEXT_VIEW"]) {
        NSDictionary *senderDict = sender;
        
        EditTextViewViewController *vc = segue.destinationViewController;
        vc.finishedEditingBlock = senderDict[@"sender"];
        vc.defaultValue = senderDict[@"default"];
        vc.canBeEmpty = [senderDict[@"canBeEmpty"] boolValue];
    }
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: { // Profile+Cover images.
            switch (indexPath.row) {
                case 0: { // Profile image.
                    imagePickerMode = IMAGE_PICKER_MODE_AVATAR;
                    
                    [self onClickImage];
                    
                    break;
                }
                case 1: { // Cover image.
                    imagePickerMode = IMAGE_PICKER_MODE_COVER;
                    
                    [self onClickImage];
                    
                    break;
                }
            }
            
            break;
        }
        case 1: {
            if (indexPath.row == 0) // Edit password
                [self performSegueWithIdentifier:@"SEGUE_EDIT_PASSWORD" sender:nil];
            
            break;
        }
        case 2: { // User info.
            NSString *segue;
            id sender;
            id defaultValue;
            BOOL canBeEmpty = NO;
            
            switch (indexPath.row) {
                case 0: { // First name
                    segue = @"SEGUE_EDIT_TEXT_FIELD";
                    defaultValue = firstNameLabel.text;
                    canBeEmpty = NO;
                    void (^finishBlock)(NSString *) = ^(NSString *text) {
                        firstNameLabel.text = text;
                    };
                    
                    sender = finishBlock;
                    
                    break;
                }
                case 1: { // Last name
                    segue = @"SEGUE_EDIT_TEXT_FIELD";
                    defaultValue = lastNameLabel.text;
                    canBeEmpty = NO;
                    void (^finishBlock)(NSString *) = ^(NSString *text) {
                        lastNameLabel.text = text;
                    };
                    
                    sender = finishBlock;
                    
                    break;
                }
                case 2: { // Email
                    segue = @"SEGUE_EDIT_TEXT_FIELD";
                    defaultValue = emailLabel.text;
                    canBeEmpty = NO;
                    void (^finishBlock)(NSString *) = ^(NSString *text) {
                        emailLabel.text = text;
                    };
                    
                    sender = finishBlock;
                    
                    break;
                }
                case 3: { // About
                    segue = @"SEGUE_EDIT_TEXT_VIEW";
                    defaultValue = aboutLabel.text;
                    canBeEmpty = YES;
                    void (^finishBlock)(NSString *) = ^(NSString *text) {
                        aboutLabel.text = text;
                    };
                    
                    sender = finishBlock;
                    
                    break;
                }
                case 4: { // Website
                    segue = @"SEGUE_EDIT_TEXT_FIELD";
                    defaultValue = websiteLabel.text;
                    canBeEmpty = YES;
                    void (^finishBlock)(NSString *) = ^(NSString *text) {
                        websiteLabel.text = text;
                    };
                    
                    sender = finishBlock;
                    
                    break;
                }
            }
            
            if (segue && sender)
                [self performSegueWithIdentifier:segue sender:@{@"sender":sender, @"default":defaultValue ? defaultValue : @"", @"canBeEmpty":@(canBeEmpty)}];
            
            break;
        }
    }
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Edit Profile";
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    useButton.frame = CGRectMake(0, 0, 50, 30);
    useButton.layer.cornerRadius = 4;
    [useButton setTitle:@"Save" forState:UIControlStateNormal];
    useButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    useButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [useButton addTarget:self action:@selector(onClickSave:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIBarButtonItem *useItem = [[UIBarButtonItem alloc] initWithCustomView:useButton];
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, useItem]];
}

- (void)setupDefaultImage {
    UIImage *i = [UIImage imageNamed:@"header_upsidedown.png"];
    UIImage *darken = [i colorizeImagWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
    UIImage *blur = [darken blurredImageWithRadius:40 iterations:2 tintColor:nil];
    
    defaultBlurredImage = blur;
}

- (void)setupImageViews {
    avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2;
    
    coverImage.image = defaultBlurredImage;
    coverImage.layer.cornerRadius = coverImage.frame.size.width / 2;
}

@end
