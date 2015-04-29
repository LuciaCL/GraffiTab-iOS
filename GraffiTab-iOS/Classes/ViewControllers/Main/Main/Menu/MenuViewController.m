//
//  MenuViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MenuViewController.h"
#import "LogoutTask.h"
#import "HomeViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "FollowersViewController.h"
#import "FollowingViewController.h"
#import "FacebookUtils.h"
#import "UserStreamablesViewController.h"
#import "NewestViewController.h"
#import "PopularViewController.h"
#import "FavouritesViewController.h"
#import "UserProfileViewController.h"

@interface MenuViewController () {
    
    IBOutlet UIImageView *avatarImage;
    IBOutlet UILabel *usernameField;
    IBOutlet UILabel *nameField;
    IBOutlet UILabel *messagesBadge;
    IBOutlet UILabel *notificationsBadge;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClickOpenMenu) name:SlideNavigationControllerDidOpen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateUnseenItems) name:NOTIFICATION_UPDATE_UNSEEN_ITEMS object:nil];
    
    [self setupImageViews];
    [self setupTableView];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupBadges];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickLogout {
    [[LoadingViewManager getInstance] addLoadingToView:[SlideNavigationController sharedInstance].view withMessage:@"Processing"];
    
    LogoutTask *task = [LogoutTask new];
    [task logoutWithSuccessBlock:^(ResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        [self doLogoutUser];
    } failureBlock:^(ResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (response.reason == AUTHORIZATION_NEEDED)
            [self doLogoutUser];
        else
            [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"We couldn't process your request right now. Please try again." closeButtonTitle:@"OK" duration:0.0f];
    }];
}

- (void)onClickConnectFacebook {
    [FacebookUtils connectFacebook];
}

- (void)onClickOpenMenu {
    [self doUpdateUnseenItems];
    
    [self loadData];
}

- (void)doLogoutUser {
    [Utils logoutUserAndShowLoginController];
}

- (void)doUpdateUnseenItems {
    HomeViewController *vc = [SlideNavigationController sharedInstance].viewControllers[0];
    
    messagesBadge.text = vc.unseenMessagesCount > 0 ? [@(vc.unseenMessagesCount) stringValue] : nil;
    notificationsBadge.text = vc.unseenNotificationsCount > 0 ? [@(vc.unseenNotificationsCount) stringValue] : nil;
    
    [self setupBadges];
}

#pragma mark - Load data

- (void)loadData {
    usernameField.text = [Settings getInstance].user.mentionUsername;
    nameField.text = [Settings getInstance].user.fullName;
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __strong typeof(self) weakSelf = self;
    
    if ([Settings getInstance].user.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:[Settings getInstance].user.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [avatarImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [cell setSelectedBackgroundView:bgColorView];
    
    UIImage *i = cell.imageView.image;
    cell.imageView.image = [i imageWithTint:[UIColor whiteColor]];
    
    UIImageView *v = (UIImageView *)[cell.contentView viewWithTag:1];
    if (v) {
        UIImage *i = v.image;
        v.image = [i imageWithTint:[UIColor whiteColor]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    
    if (indexPath.section == 0) { // User profile
        switch (indexPath.row) {
            case 0: { // Profile
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
                    [ViewControllerUtils showUserProfile:[Settings getInstance].user fromViewController:[SlideNavigationController sharedInstance]];
                }];
                
                break;
            }
            case 1: { // Notifications
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
                
                break;
            }
            case 2: { // Messages
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ConversationsViewController"];
                
                break;
            }
            case 3: { // Graffiti
                UserStreamablesViewController *streamables = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserStreamablesViewController"];
                streamables.user = [Settings getInstance].user;
                
                vc = streamables;
                
                break;
            }
            case 4: { // Favourites
                FavouritesViewController *followers = [mainStoryboard instantiateViewControllerWithIdentifier:@"FavouritesViewController"];
                followers.user = [Settings getInstance].user;
                
                vc = followers;
                
                break;
            }
            case 5: { // Followers
                FollowersViewController *followers = [mainStoryboard instantiateViewControllerWithIdentifier:@"FollowersViewController"];
                followers.user = [Settings getInstance].user;
                
                vc = followers;
                
                break;
            }
            case 6: { // Following
                FollowingViewController *following = [mainStoryboard instantiateViewControllerWithIdentifier:@"FollowingViewController"];
                following.user = [Settings getInstance].user;
                
                vc = following;
                
                break;
            }
            case 7: { // Places
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
                
                break;
            }
        }
    }
    else if (indexPath.section == 1) { // Discover
        switch (indexPath.row) {
            case 0: { // Graffiti Map
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"GraffitiMapViewController"];
                
                break;
            }
            case 1: { // Popular
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"PopularViewController"];
                
                break;
            }
            case 2: { // Most recent
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewestViewController"];
                
                break;
            }
            case 3: // Most active users
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MostActiveUsersViewController"];
                
                break;
        }
    }
    else if (indexPath.section == 2) { // Search
        switch (indexPath.row) {
            case 0: { // Search
                UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
                
                [[SlideNavigationController sharedInstance] presentViewController:vc animated:YES completion:^{
                    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                }];
                
                break;
            }
            case 1: { // Social friends
                if (FBSession.activeSession.state == FBSessionStateOpen)
                    vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SocialFriendsViewController"];
                else {
                    [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
                        SCLAlertView *alert = [[SCLAlertView alloc] init];
                        
                        [alert addButton:@"Connect with Facebook" actionBlock:^(void) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [self onClickConnectFacebook];
                            });
                        }];
                        
                        [alert showTitle:[SlideNavigationController sharedInstance] title:APP_NAME subTitle:@"This action requires you to login with Facebook. Would you like to connect your account with Facebook?" style:Notice closeButtonTitle:@"Cancel" duration:0.0f];
                    }];
                }
                
                break;
            }
        }
    }
    else if (indexPath.section == 3) { // Settings
        switch (indexPath.row) {
            case 0: { // Settings
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                
                break;
            }
            case 1: { // Logout
                [[SlideNavigationController sharedInstance] closeMenuWithCompletion:^{
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    
                    [alert addButton:@"Log out" actionBlock:^(void) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self onClickLogout];
                        });
                    }];
                    
                    [alert showTitle:[SlideNavigationController sharedInstance] title:APP_NAME subTitle:@"Are you sure you want to log out?" style:Warning closeButtonTitle:@"Cancel" duration:0.0f];
                }];
                
                break;
            }
        }
    }
    
    if (vc) {
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:NO
                                                                         andCompletion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    customView.backgroundColor = [UIColor colorWithWhite:255 alpha:0.11];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(10, 15, 200, 25);
    headerLabel.textColor = [UIColor whiteColor];
    
    switch ( section ) {
        case 1:
            headerLabel.text = @"DISCOVER";
            break;
        case 2:
            headerLabel.text = @"SEARCH";
            break;
        case 3:
            headerLabel.text = @"SETTINGS";
            break;
        default:
            break;
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 0 : 40;
}

#pragma mark - Setup

- (void)buildBadge:(UILabel *)badge {
    if ([badge.text isEqualToString:@"0"] || badge.text.length <= 0)
        badge.hidden = YES;
    else
        badge.hidden = NO;
    
    badge.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    badge.textColor = [UIColor whiteColor];
    
    [badge sizeToFit];
    
    CGRect f = badge.frame;
    f.size.height = 20;
    f.size.width += 12;
    f.origin.x = self.view.frame.size.width - f.size.width - 10;
    badge.frame = f;
    
    badge.layer.cornerRadius = badge.frame.size.height / 2;
    [badge.layer setMasksToBounds:YES];
}

- (void)setupBadges {
    [self buildBadge:notificationsBadge];
    [self buildBadge:messagesBadge];
}

- (void)setupImageViews {
    avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2;
    avatarImage.layer.borderWidth = 2;
    avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setupTableView {
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_background.jpg"]]];
}

@end
