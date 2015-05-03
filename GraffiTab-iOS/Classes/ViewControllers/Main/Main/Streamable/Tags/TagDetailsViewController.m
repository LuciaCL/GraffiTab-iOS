//
//  TagDetailsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 30/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsViewController.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "RTSpinKitView.h"
#import "UserProfileViewController.h"
#import "UIActionSheet+Blocks.h"
#import "PaintingViewController.h"
#import "AppDelegate.h"

@interface TagDetailsViewController () {
    
    IBOutlet UIImageView *avatarView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet ZoomableNormalImageView *itemImage;
    IBOutlet UILabel *likesLabel;
    IBOutlet UILabel *commentsLabel;
    IBOutlet UIView *gradientView;
    IBOutlet UIView *topGradientView;
    IBOutlet UIButton *closeBtn;
    IBOutlet UIImageView *likeImage;
    IBOutlet UIImageView *commentImage;
    IBOutlet UIImageView *menuImage;
    
    RTSpinKitView *loadingIndicator;
    WYPopoverController *settingsPopoverController;
}

- (IBAction)onClickClose:(id)sender;
- (IBAction)onClickOwner:(id)sender;
- (IBAction)onClickLabelComment:(id)sender;
- (IBAction)onClickLabelLike:(id)sender;
- (IBAction)onClickLike:(id)sender;
- (IBAction)onClickMenu:(id)sender;

@end

@implementation TagDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
    [self setupImageViews];
    [self setupLabels];
    
    [self loadItemInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupLoadingIndicator];
    
    if (!self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickMenu:(id)sender {
    NSMutableArray *actions;
    
    if ([self.item.user isEqual:GTLifecycleManager.user])
        actions = [NSMutableArray arrayWithArray:@[@"Edit", self.item.isPrivate ? @"Make public" : @"Make private", @"Delete"]];
    
    [actions addObjectsFromArray:@[@"Save to Camera Roll", @"Flag as inappropriate"]];
    
    [UIActionSheet showInView:self.view
                    withTitle:[NSString stringWithFormat:@"What would you like to do?"]
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:actions
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit"]) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                 UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
                                 PaintingViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"PaintingViewController"];
                                 vc.toEdit = self.item;
                                 vc.toEditImage = itemImage.imageView.image;
                                 
                                 [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                                     [[ViewControllerUtils getVisibleViewController] presentViewController:vc animated:YES completion:nil];
                                 }];
                             });
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Save to Camera Roll"])
                             UIImageWriteToSavedPhotosAlbum(itemImage.imageView.image, nil, nil, nil);
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Flag as inappropriate"]) {
                             [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to flag this item as inappropriate?" yesTitle:@"Flag" noTitle:@"Cancel" yesBlock:^{
                                 [GTStreamableManager flagItemWithId:self.item.streamableId successBlock:^(GTResponseObject *response) {
                                     self.item.isFlagged = YES;
                                 } failureBlock:^(GTResponseObject *response) {
                                     [self handleError:response];
                                 }];
                             } noBlock:^{}];
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Make public"]) {
                             [GTStreamableManager makeItemPublicWithId:self.item.streamableId successBlock:^(GTResponseObject *response) {
                                 self.item.isPrivate = NO;
                             } failureBlock:^(GTResponseObject *response) {
                                 [self handleError:response];
                             }];
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Make private"]) {
                             [GTStreamableManager makeItemPrivateWithId:self.item.streamableId successBlock:^(GTResponseObject *response) {
                                 self.item.isPrivate = YES;
                             } failureBlock:^(GTResponseObject *response) {
                                 [self handleError:response];
                             }];
                         }
                         else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
                             [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to delete this item?" yesTitle:@"Delete" noTitle:@"Cancel" yesBlock:^{
                                 [[LoadingViewManager getInstance] addLoadingToView:self.view withMessage:@"Processing"];
                                
                                 NSMutableArray *idsToDelete = [NSMutableArray arrayWithObject:@(self.item.streamableId)];
                                 
                                 [GTStreamableManager deleteItemsWithIds:idsToDelete successBlock:^(GTResponseObject *response) {
                                     [[LoadingViewManager getInstance] removeLoadingView];
                                     
                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                         [self onClickClose:nil];
                                     });
                                 } failureBlock:^(GTResponseObject *response) {
                                     [[LoadingViewManager getInstance] removeLoadingView];
                                     
                                     [self handleError:response];
                                 }];
                             } noBlock:^{}];
                         }
                     }];
}

- (IBAction)onClickLike:(id)sender {
    if (self.item.isLiked) { // Unlike item.
        self.item.likesCount--;
        
        [GTStreamableManager unlikeItemWithId:self.item.streamableId successBlock:^(GTResponseObject *response) {
            [self loadItemInfo];
        } failureBlock:^(GTResponseObject *response) {
            [self handleError:response];
        }];
    }
    else { // Like item.
        self.item.likesCount++;
        
        [GTStreamableManager likeItemWithId:self.item.streamableId successBlock:^(GTResponseObject *response) {
            [self loadItemInfo];
        } failureBlock:^(GTResponseObject *response) {
            [self handleError:response];
        }];
    }
    
    self.item.isLiked = !self.item.isLiked;
    
    [self loadItemInfo];
}

- (IBAction)onClickClose:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];

}

- (IBAction)onClickOwner:(id)sender {
    [ViewControllerUtils showUserProfile:self.item.user fromViewController:self];
}

- (IBAction)onClickLabelLike:(id)sender {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    LikesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    vc.item = self.item;
    vc.embedded = YES;
    
    [self showFormSheet:vc forView:likeImage];
    vc.parentPopover = settingsPopoverController;
    vc.parent = self;
}

- (IBAction)onClickLabelComment:(id)sender {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    CommentsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    vc.item = self.item;
    vc.embedded = YES;
    
    [self showFormSheet:vc forView:commentImage];
    vc.parentPopover = settingsPopoverController;
    vc.parent = self;
}

- (void)onSwipeDown {
    [self onClickClose:nil];
}

- (void)showFormSheet:(UIViewController *)vc forView:(UIView *)view {
    vc.preferredContentSize = CGSizeMake(300, 350);
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    settingsPopoverController = [[WYPopoverController alloc] initWithContentViewController:nav];
    settingsPopoverController.delegate = self;
    settingsPopoverController.wantsDefaultContentAppearance = YES;
    
    [settingsPopoverController presentPopoverFromRect:view.bounds
                                               inView:view
                             permittedArrowDirections:WYPopoverArrowDirectionAny
                                             animated:YES
                                              options:WYPopoverAnimationOptionFadeWithScale];
    
}

#pragma mark - Error handler

- (void)handleError:(GTResponseObject *)response {
    if (response.reason == AUTHORIZATION_NEEDED) {
        [Utils logoutUserAndShowLoginController];
        [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
    }
    else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
        [Utils showMessage:APP_NAME message:response.message];
}

#pragma mark - Loading

- (void)loadItemInfo {
    dateLabel.text = [DateUtils timePassedSinceDate:self.item.date];
    
    // Setup labels.
    usernameLabel.text = self.item.user.fullName;
    likesLabel.text = [NSString stringWithFormat:@"%i", self.item.likesCount];
    commentsLabel.text = [NSString stringWithFormat:@"%i", self.item.commentsCount];
    
    // Setup buttons.
    if (self.item.isLiked)
        likeImage.image = [UIImage imageNamed:@"unlike.png"];
    else
        likeImage.image = [UIImage imageNamed:@"like.png"];
    
    [self loadAvatar];
    [self loadItem];
    
    [self layoutStats];
}

- (void)layoutStats {
    [likesLabel sizeToFit];
    [commentsLabel sizeToFit];
    
    CGRect f = likesLabel.frame;
    f.origin.x = self.view.frame.size.width - f.size.width - 15;
    likesLabel.frame = f;
    
    CGPoint c = likesLabel.center;
    c.y = likeImage.center.y + 3;
    likesLabel.center = c;
    
    f = likeImage.frame;
    f.origin.x = likesLabel.frame.origin.x - f.size.width - 7;
    likeImage.frame = f;
    
    f = commentsLabel.frame;
    f.origin.x = likeImage.frame.origin.x - 25;
    commentsLabel.frame = f;
    
    c = commentsLabel.center;
    c.y = likeImage.center.y + 3;
    commentsLabel.center = c;
    
    f = commentImage.frame;
    f.origin.x = commentsLabel.frame.origin.x - f.size.width - 7;
    commentImage.frame = f;
}

- (void)loadAvatar {
    __strong typeof(self) weakSelf = self;
    
    if (self.item.user.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:self.item.user.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        avatarView.image = nil;
        [avatarView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:weakSelf->avatarView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf->avatarView.image = image;
                            } completion:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf->avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

- (void)loadItem {
    [loadingIndicator startAnimating];
    
    __strong typeof(self) weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetFullGraffiti:self.item.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    itemImage.imageView.image = nil;
    [itemImage.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:weakSelf->itemImage.imageView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            weakSelf->itemImage.imageView.image = image;
                        } completion:^(BOOL finished) {
                            [weakSelf->loadingIndicator stopAnimating];
                        }];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf->itemImage.imageView.image = nil;
        
        [weakSelf->loadingIndicator stopAnimating];
    }];
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController {
    return NO;
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value {
    // keyboard is shown and the popover will be moved up by 163 pixels for example ( *value = 163 )
    *value = 140; // set value to 0 if you want to avoid the popover to be moved
}

#pragma mark - ZoomableNormalImageViewDelegate

- (void)didTapImageView:(ZoomableNormalImageView *)imageView {
    if (topGradientView.alpha <= 0) {
        [Utils showView:topGradientView];
        [Utils showView:gradientView];
    }
    else {
        [Utils hideView:topGradientView];
        [Utils hideView:gradientView];
    }
}

- (void)didZoomImageView:(ZoomableNormalImageView *)imageView {
    [Utils hideView:topGradientView];
    [Utils hideView:gradientView];
}

#pragma mark - Setup

- (void)setupView {
    UISwipeGestureRecognizer* rec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeDown)];
    rec.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:rec];
}

- (void)setupImageViews {
    itemImage.delegate = self;
    
    avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
    avatarView.layer.borderWidth = 2;
    avatarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    likeImage.image = [likeImage.image imageWithTint:[UIColor lightGrayColor]];
    menuImage.image = [menuImage.image imageWithTint:[UIColor lightGrayColor]];
    [closeBtn setImage:[closeBtn.imageView.image imageWithTint:[UIColor lightGrayColor]] forState:UIControlStateNormal];
}

- (void)setupLabels {
    usernameLabel.textColor = [UIColor lightGrayColor];
    dateLabel.textColor = UIColorFromRGB(COLOR_ORANGE);
}

- (void)setupLoadingIndicator {
    if (!loadingIndicator) {
        loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor whiteColor]];
        loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
        [self.view addSubview:loadingIndicator];
    }
    
    loadingIndicator.center = itemImage.center;
}

@end
