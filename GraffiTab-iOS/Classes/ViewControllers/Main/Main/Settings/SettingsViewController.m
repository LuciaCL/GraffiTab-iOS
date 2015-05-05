//
//  SettingsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SettingsViewController.h"
#import "FacebookUtils.h"
#import "UIActionSheet+Blocks.h"

@interface SettingsViewController () {
    
    IBOutlet UIImageView *facebookImage;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
    [self setupImageViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
}

#pragma mark - Logout

- (void)onClickLogout {
    [[LoadingViewManager getInstance] addLoadingToView:[SlideNavigationController sharedInstance].view withMessage:@"Processing"];
    
    [GTUserManager logoutWithSuccessBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        [self doLogoutUser];
    } failureBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (response.reason == AUTHORIZATION_NEEDED)
            [self doLogoutUser];
        else
            [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"We couldn't process your request right now. Please try again." closeButtonTitle:@"OK" duration:0.0f];
    }];
}

- (void)doLogoutUser {
    [Utils logoutUserAndShowLoginController];
}

- (void)onClickConnectFacebook {
    [FacebookUtils connectFacebook];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { // Find Facebook friends
                    if (FBSession.activeSession.state == FBSessionStateOpen)
                        [self showController:[mainStoryboard instantiateViewControllerWithIdentifier:@"SocialFriendsViewController"]];
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
                case 1: { // Invite friends
                    NSString *textToShare = @"Download the GraffiTab app for FREE from the App Store.";
                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
                    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //Exclude whichever aren't relevant
                    [self presentViewController:activityVC animated:YES completion:nil];
                    
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: { // Edit profile
                    [self showController:[mainStoryboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"]];
                    
                    break;
                }
                case 1: { // Change password
                    [self showController:[mainStoryboard instantiateViewControllerWithIdentifier:@"EditPasswordViewController"]];
                    
                    break;
                }
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: { // Help center
                    break;
                }
                case 1: { // Report a problem
                    [UIActionSheet showInView:self.view
                                    withTitle:@"Report a Problem"
                            cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil
                            otherButtonTitles:@[@"Something went wrong", @"General feedback"]
                                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                                             return;
                                         
                                         if (buttonIndex == 0)
                                             [self performSegueWithIdentifier:@"SEGUE_PROBLEM" sender:nil];
                                         else if (buttonIndex == 1)
                                             [self performSegueWithIdentifier:@"SEGUE_FEEDBACK" sender:nil];
                                     }];
                    
                    break;
                }
            }
            break;
        }
        case 3: {
            switch (indexPath.row) {
                case 0: { // Terms and Conditions
                    [self showInfoController:[[NSBundle mainBundle] pathForResource:@"terms" ofType:@"txt"] title:@"Terms of Use"];
                    
                    break;
                }
                case 1: { // EULA
                    [self showInfoController:[[NSBundle mainBundle] pathForResource:@"eula" ofType:@"txt"] title:@"End User License Agreement"];
                    
                    break;
                }
                case 2: { // Credits
                    [self showInfoController:[[NSBundle mainBundle] pathForResource:@"credits" ofType:@"txt"] title:@"Credits"];
                    
                    break;
                }
                case 3: { // About
                    [self performSegueWithIdentifier:@"SEGUE_ABOUT" sender:nil];
                    
                    break;
                }
            }
            break;
        }
        case 4: {
            switch (indexPath.row) {
                case 0: { // Logout
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    
                    [alert addButton:@"Log out" actionBlock:^(void) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self onClickLogout];
                        });
                    }];
                    
                    [alert showTitle:[SlideNavigationController sharedInstance] title:APP_NAME subTitle:@"Are you sure you want to log out?" style:Warning closeButtonTitle:@"Cancel" duration:0.0f];
                    
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Settings";
}

- (void)setupImageViews {
    facebookImage.image = [facebookImage.image imageWithTint:UIColorFromRGB(COLOR_MAIN)];
}

@end
