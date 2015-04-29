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
#import "EditAvatarTask.h"
#import "EditCoverTask.h"
#import "FollowersViewController.h"
#import "FollowingViewController.h"
#import "UserStreamablesViewController.h"
#import "UserTitleHeader.h"
#import "GetUserProfileTask.h"
#import "ProfileDetailsCell.h"
#import "ProfileAboutCell.h"
#import "FollowTask.h"
#import "UnfollowTask.h"
#import "ProfileAssetsCell.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "GetUserItemsTask.h"
#import "STFullSizeTableCellFactory.h"
#import "TagDetailsViewController.h"
#import "LikeItemTask.h"
#import "UnlikeItemTask.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "EXPhotoViewer.h"
#import "UIWindow+PazLabs.h"
#import "TagDetailsBounceTransitioningDelegate.h"
#import "FindUserForUsernameTask.h"
#import "CreateConversationViewController.h"

#define IMAGE_PICKER_MODE_AVATAR 0
#define IMAGE_PICKER_MODE_COVER 1

@interface UserProfileViewController () {
    
    UserTitleHeader *statusBarBackground;
    HeaderViewWithImage *headerView;
    
    TagDetailsBounceTransitioningDelegate *transitioningDelegate;
    BOOL initiallyRefreshed;
    BOOL initiallyLoaded;
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
    int imagePickerMode;
    UIImagePickerController *galleryPicker;
}

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    transitioningDelegate = [TagDetailsBounceTransitioningDelegate new];
    offset = 0;
    canLoadMore = YES;
    isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupStatusBar];
    [self setupTableView];
    [self setupHeader];
    
    if (self.user) {
        [self loadItem];
        [self.tableView ins_beginInfinityScroll];
    }
    else // We need to first check if the user exists.
        [self findUserForUsername];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    if (!self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (initiallyRefreshed && self.user) {
        if ([self.user isEqual:[Settings getInstance].user])
            self.user = [Settings getInstance].user;
        
        // Refresh user state.
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
    }
    
    initiallyRefreshed = YES;
}

- (void)dealloc {
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
    
    [EXPhotoViewer showImageFrom:i rootViewController:[[UIApplication sharedApplication].keyWindow visibleViewController]];
}

- (void)changeImage:(UIImage *)image {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    if (imagePickerMode == IMAGE_PICKER_MODE_AVATAR) {
        EditAvatarTask *task = [EditAvatarTask new];
        [task editAvatarWithNewImage:image successBlock:^(ResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            self.user = [Settings getInstance].user;
            
            headerView.item = self.user;
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
            
            self.user = [Settings getInstance].user;
            
            headerView.item = self.user;
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

- (BOOL)canEdit {
    return [self.user isEqual:[Settings getInstance].user];
}

#pragma mark - Loading

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    isDownloading = YES;
    
    GetUserItemsTask *task = [GetUserItemsTask new];
    task.isStart = isStart;
    [task getItemsWithUserId:self.user.userId start:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
        if (o == 0)
            [items removeAllObjects];
        
        [items addObjectsFromArray:response.object];
        
        if ([response.object count] <= 0 || [response.object count] < MAX_ITEMS)
            canLoadMore = NO;
        
        [self finalizeLoad];
    } cacheBlock:^(ResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(ResponseObject *response) {
        canLoadMore = NO;
        
        [self finalizeLoad];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)finalizeCacheLoad {
    [self.tableView reloadData];
}

- (void)finalizeLoad {
    isDownloading = NO;
    [self.tableView ins_endInfinityScroll];
    [self.tableView ins_setInfinityScrollEnabled:canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
    GetUserProfileTask *task = [GetUserProfileTask new];
    [task getUserProfileWithId:self.user.userId successBlock:^(ResponseObject *response) {
        self.user = response.object;
        
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
    } failureBlock:^(ResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)findUserForUsername {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    FindUserForUsernameTask *task = [FindUserForUsernameTask new];
    [task findUserForUsername:self.usernameToSearch successBlock:^(ResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        // User with that username exists, so reset all data.
        self.user = response.object;
        
        headerView.item = self.user;
        statusBarBackground.item = self.user;
        
        [self.tableView reloadData];
        [self.tableView ins_beginInfinityScroll];
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
    
    Person *p = self.user;
    
    if (p.isFollowing) { // Unfollow user.
        p.followersCount--;
        
        UnfollowTask *task = [UnfollowTask new];
        [task unfollowUserWithId:p.userId successBlock:^(ResponseObject *response) {
            Person *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
            p.followersCount = responsePerson.followersCount;
            p.followeesCount = responsePerson.followeesCount;
            
            [self.tableView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Follow user.
        p.followersCount++;
        
        FollowTask *task = [FollowTask new];
        [task followUserWithId:p.userId successBlock:^(ResponseObject *response) {
            Person *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
            p.followersCount = responsePerson.followersCount;
            p.followeesCount = responsePerson.followeesCount;
            
            [self.tableView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
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

- (void)didTapLike:(Streamable *)p {
    if (p.isLiked) { // Unlike item.
        UnlikeItemTask *task = [UnlikeItemTask new];
        [task unlikeItemWithId:p.streamableId successBlock:^(ResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.tableView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Like item.
        LikeItemTask *task = [LikeItemTask new];
        [task likeItemWithId:p.streamableId successBlock:^(ResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.tableView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.tableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isLiked = !p.isLiked;
    
    [self.tableView reloadData];
}

- (void)didTapComment:(Streamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    CommentsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapLikesLabel:(Streamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    LikesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapOwner:(Streamable *)item {
    
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
            Streamable *n = items[indexPath.row];
            
            if ([n isKindOfClass:[StreamableTag class]])
                height = [STTagFullSizeTableCell height];
            else if ([n isKindOfClass:[StreamableVideo class]])
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
            Streamable *n = items[indexPath.row];
            
            if ([n isKindOfClass:[StreamableTag class]])
                [ViewControllerUtils showTag:(StreamableTag *) n fromViewController:self originFrame:CGRectNull transitionDelegate:transitioningDelegate];
            else if ([n isKindOfClass:[StreamableVideo class]]) {
                
            }
            
            break;
        }
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
    self.tableView.contentInset = UIEdgeInsetsMake(-STATUSBAR_HEIGHT, 0, -(STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT), 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(-STATUSBAR_HEIGHT, 0, 0, 0);
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:[STTagFullSizeTableCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[STTagFullSizeTableCell reusableIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[STVideoFullSizeTableCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[STVideoFullSizeTableCell reusableIdentifier]];
    
    // Setup pull-to-refresh
    __strong typeof(self) weakSelf = self;
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf->canLoadMore && !weakSelf->isDownloading) {
            if (weakSelf->initiallyLoaded)
                weakSelf->offset += MAX_ITEMS;
            
            weakSelf->initiallyLoaded = YES;
            
            [weakSelf loadItems:NO withOffset:weakSelf->offset];
        }
        else {
            weakSelf->isDownloading = NO;
            
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
