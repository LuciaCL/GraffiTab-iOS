//
//  UserProfileViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIActionSheet+Blocks.h"
#import "ImageCropViewController.h"
#import "FollowersViewController.h"
#import "FollowingViewController.h"
#import "UserStreamablesViewController.h"
#import "UserTitleHeader.h"
#import "ProfileDetailsCell.h"
#import "ProfileAboutCell.h"
#import "ProfileAssetsCell.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "STFullSizeTableCellFactory.h"
#import "TagDetailsViewController.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "EXPhotoViewer.h"
#import "CreateConversationViewController.h"

#define IMAGE_PICKER_MODE_AVATAR 0
#define IMAGE_PICKER_MODE_COVER 1

@interface UserProfileViewController () {
    
    UserTitleHeader *statusBarBackground;
    HeaderViewWithImage *headerView;
    
    BOOL initiallyRefreshed;
    NSMutableArray *items;
    int imagePickerMode;
    UIImagePickerController *galleryPicker;
    NSMutableSet *shownIndexes;
}

@property (nonatomic, assign) BOOL initiallyLoaded;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) int offset;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offset = 0;
    self.canLoadMore = YES;
    self.isDownloading = NO;
    items = [NSMutableArray new];
    shownIndexes = [NSMutableSet set];
    
    [self setupStatusBar];
    [self setupTableView];
    [self setupHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    if (!self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (initiallyRefreshed && self.user) {
        if ([self.user isEqual:[GTLifecycleManager user]])
            self.user = [GTLifecycleManager user];
        
        // Refresh user state.
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
    }
    else if (!initiallyRefreshed) {
        if (self.user) {
            [self loadItem];
            [self.tableView ins_beginInfinityScroll];
        }
        else // We need to first check if the user exists.
            [self findUserForUsername];
    }
    
    initiallyRefreshed = YES;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    [self.tableView ins_removeInfinityScroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickImage {
    NSArray *actions;
    
    if ([self canEdit])
        actions = @[@"View image", @"Change image", @"Remove image"];
    else
        actions = @[@"View image", @"Save to Camera Roll"];
    
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
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save to Camera Roll"])
                             [self saveToCameraRoll];
                     }];
}

#pragma mark - Profile actions

- (void)saveToCameraRoll {
    UIImage *i;
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR)
        i = headerView.avatarView.image;
    else if (imagePickerMode == IMAGE_PICKER_MODE_COVER)
        i = headerView.coverView.image;
    
    UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil);
}

- (void)viewImage {
    UIImageView *i;
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR)
        i = headerView.avatarView;
    else if (imagePickerMode == IMAGE_PICKER_MODE_COVER)
        i = headerView.coverView;
    
    [EXPhotoViewer showImageFrom:i rootViewController:[ViewControllerUtils getVisibleViewController]];
}

- (void)changeImage:(UIImage *)image {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR) {
        [GTUserManager editAvatarWithNewImage:image successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            self.user = [GTLifecycleManager user];
            
            headerView.item = self.user;
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
    else if (imagePickerMode == IMAGE_PICKER_MODE_COVER) {
        [GTUserManager editCoverWithNewImage:image successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            self.user = [GTLifecycleManager user];
            
            headerView.item = self.user;
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

- (BOOL)canEdit {
    return [self.user isEqual:[GTLifecycleManager user]];
}

#pragma mark - Loading

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    self.isDownloading = YES;
    
    [GTStreamableManager getItemsWithUserId:self.user.userId start:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        if (o == 0)
            [items removeAllObjects];
        
        [items addObjectsFromArray:response.object];
        
        if ([response.object count] <= 0 || [response.object count] < MAX_ITEMS)
            self.canLoadMore = NO;
        
        [self finalizeLoad];
    } cacheBlock:^(GTResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(GTResponseObject *response) {
        self.canLoadMore = NO;
        
        [self finalizeLoad];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)finalizeCacheLoad {
    [self.tableView reloadData];
}

- (void)finalizeLoad {
    self.isDownloading = NO;
    [self.tableView ins_endInfinityScroll];
    [self.tableView ins_setInfinityScrollEnabled:self.canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (self.offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        [self checkNoItemsHeader];
    });
}

- (void)checkNoItemsHeader {
    if (items.count <= 0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        self.tableView.tableFooterView = l;
    }
    else
        self.tableView.tableFooterView = nil;
}

- (void)loadItem {
    [GTUserManager getUserProfileWithId:self.user.userId successBlock:^(GTResponseObject *response) {
        self.user = response.object;
        
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)findUserForUsername {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    [GTUserManager findUserForUsername:self.usernameToSearch successBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        // User with that username exists, so reset all data.
        self.user = response.object;
        
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
        [self.tableView ins_beginInfinityScroll];
    } failureBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == NOT_FOUND)
            [Utils showMessage:APP_NAME message:@"This user does not exist."];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sv {
    [self.tableView shouldPositionParallaxHeader];
    
    // This is how you can implement appearing or disappearing of sticky view.
    [self.tableView.parallaxHeader.stickyView setAlpha:self.tableView.parallaxHeader.progress];
    
    statusBarBackground.alpha = 1.0 - self.tableView.parallaxHeader.progress;

    headerView.backButton.alpha = self.tableView.parallaxHeader.progress;
    headerView.settingsButton.alpha = self.tableView.parallaxHeader.progress;
}

#pragma mark - UserHeaderDelegate

- (void)didTapBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapSettings {
    if (!self.user)
        return;
    
    [self performSegueWithIdentifier:@"SEGUE_EDIT_PROFILE" sender:nil];
}

- (void)didTapMessage {
    if (!self.user)
        return;
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CreateConversationViewController"];
    CreateConversationViewController *convVc = vc.viewControllers.firstObject;
    convVc.selectedUser = self.user;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didTapFollow {
    if (!self.user)
        return;
    
    GTPerson *p = self.user;
    
    if (p.isFollowing) { // Unfollow user.
        p.followersCount--;
        
        [GTUserManager unfollowUserWithId:p.userId successBlock:^(GTResponseObject *response) {
            GTPerson *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
            p.followersCount = responsePerson.followersCount;
            p.followeesCount = responsePerson.followeesCount;
            
            [self.tableView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Follow user.
        p.followersCount++;
        
        [GTUserManager followUserWithId:p.userId successBlock:^(GTResponseObject *response) {
            GTPerson *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
            p.followersCount = responsePerson.followersCount;
            p.followeesCount = responsePerson.followeesCount;
            
            [self.tableView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isFollowing = !p.isFollowing;
    
    [self.tableView reloadData];
}

- (void)didTapChangeAvatar {
    if (!self.user)
        return;
    
    imagePickerMode = IMAGE_PICKER_MODE_AVATAR;
    
    [self onClickImage];
}

- (void)didTapChangeCover {
    if (!self.user)
        return;
    
    imagePickerMode = IMAGE_PICKER_MODE_COVER;
    
    [self onClickImage];
}

- (void)didTapFollowers {
    if (!self.user)
        return;
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    FollowersViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FollowersViewController"];
    vc.user = self.user;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapFollowing {
    if (!self.user)
        return;
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    FollowingViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FollowingViewController"];
    vc.user = self.user;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapGraffiti {
    if (!self.user)
        return;
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UserStreamablesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserStreamablesViewController"];
    vc.user = self.user;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - StreamableTableCellDelegate

- (void)didTapLike:(GTStreamable *)p {
    if (p.isLiked) { // Unlike item.
        [GTStreamableManager unlikeItemWithId:p.streamableId successBlock:^(GTResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.tableView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Like item.
        [GTStreamableManager likeItemWithId:p.streamableId successBlock:^(GTResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.tableView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isLiked = !p.isLiked;
    
    [self.tableView reloadData];
}

- (void)didTapComment:(GTStreamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    CommentsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapShare:(GTStreamable *)item image:(UIImage *)image {
    [ShareUtils shareText:nil andImage:image andUrl:nil viewController:self];
}

- (void)didTapLikesLabel:(GTStreamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    LikesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapOwner:(GTStreamable *)item {
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
        default:
            return items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: // About.
                    return [self profileAboutCellForRowAtIndexPath:indexPath];
                default: // Profile details.
                    return [self profileDetailsCellForRowAtIndexPath:indexPath];
            }
        }
        case 1:
            return [self profileAssetsCellForRowAtIndexPath:indexPath];
        default: {
            STFullSizeTableCell *cell = [STFullSizeTableCellFactory createStreamableTableCellForStreamable:items[indexPath.row] tableView:tableView indexPath:indexPath];
            cell.delegate = self;
            
            return cell;
        }
    }
}

- (ProfileDetailsCell *)profileDetailsCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileDetailsCell *cell = (ProfileDetailsCell *)[self.tableView dequeueReusableCellWithIdentifier:[ProfileDetailsCell reusableIdentifier]];
    
    cell.item = self.user;
    cell.delegate = self;
    
    return cell;
}

- (ProfileAboutCell *)profileAboutCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileAboutCell *cell = (ProfileAboutCell *)[self.tableView dequeueReusableCellWithIdentifier:[ProfileAboutCell reusableIdentifier]];
    
    cell.item = self.user;
    
    return cell;
}

- (ProfileAssetsCell *)profileAssetsCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileAssetsCell *cell = (ProfileAssetsCell *)[self.tableView dequeueReusableCellWithIdentifier:[ProfileAssetsCell reusableIdentifier]];
    
    cell.item = self.user;
    cell.delegate = self;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [header setBackgroundColor:[UIColor clearColor]];
        
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    if (section == 1)
        return 7;
    if (section == 2)
        return 15;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { // About.
                    if (self.user.about || self.user.website) {
                        ProfileAboutCell *cell = (ProfileAboutCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
                        
                        CGRect rhs = CGRectZero;
                        rhs = CGRectUnion(rhs, cell.descriptionLabel.frame);
                        
                        return rhs.size.height + cell.descriptionLabel.frame.origin.y;
                    }
                    
                    return 0;
                }
                default: // Profile details.
                    return [ProfileDetailsCell height];
            }
        }
        case 1:
            return [ProfileAssetsCell height];
        default: {
            int height;
            GTStreamable *n = items[indexPath.row];
            
            if ([n isKindOfClass:[GTStreamableTag class]])
                height = [STTagFullSizeTableCell height];
            else if ([n isKindOfClass:[GTStreamableVideo class]])
                height = [STVideoFullSizeTableCell height];
            
            return height;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { // About.
                    if (self.user.website)
                        [Utils openUrl:self.user.website];
                    
                    break;
                }
            }
            
            break;
        }
        case 2: {
            GTStreamable *n = items[indexPath.row];
            
            if ([n isKindOfClass:[GTStreamableTag class]])
                [ViewControllerUtils showTag:(GTStreamableTag *) n fromViewController:self];
            else if ([n isKindOfClass:[GTStreamableVideo class]]) {
                
            }
            
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![shownIndexes containsObject:indexPath] && indexPath.section == 2) {
        [shownIndexes addObject:indexPath];
        
        CALayer *layer = cell.layer;
        layer.transform = CATransform3DMakeTranslation(0, self.tableView.frame.size.height - 50, 0.0f);
        
        [UIView animateWithDuration:0.8
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             cell.layer.transform = CATransform3DIdentity;
                             
                         } completion:nil];
    }
}

#pragma mark - Setup

- (void)setupStatusBar {
    statusBarBackground = [UserTitleHeader instantiateFromNib];
    statusBarBackground.item = self.user;
    statusBarBackground.alpha = 0.0;
    statusBarBackground.delegate = self;
    [self.navigationController.view addSubview:statusBarBackground];
}

- (void)setupTableView {
    self.tableView.contentInset = UIEdgeInsetsMake(-STATUSBAR_HEIGHT, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-STATUSBAR_HEIGHT, 0, 0, 0);
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:[STTagFullSizeTableCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[STTagFullSizeTableCell reusableIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[STVideoFullSizeTableCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[STVideoFullSizeTableCell reusableIdentifier]];
    
    // Setup pull-to-refresh
    __weak typeof(self) weakSelf = self;
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf.canLoadMore && !weakSelf.isDownloading) {
            if (weakSelf.initiallyLoaded)
                weakSelf.offset += MAX_ITEMS;
            
            [weakSelf loadItems:!weakSelf.initiallyLoaded withOffset:weakSelf.offset];
            
            weakSelf.initiallyLoaded = YES;
        }
        else {
            weakSelf.isDownloading = NO;
            
            [weakSelf.tableView ins_endInfinityScroll];
            [weakSelf.tableView ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    self.tableView.ins_infiniteScrollBackgroundView.preserveContentInset = YES;
}

- (void)setupHeader {
    // Setup header.
    headerView = [HeaderViewWithImage instantiateFromNib];
    headerView.item = self.user;
    headerView.delegate = self;
    [self.tableView setParallaxHeaderView:headerView mode:VGParallaxHeaderModeFill height:headerView.frame.size.height];
}

@end
