//
//  LoginHomeViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "LoginHomeViewController.h"
#import "AppDelegate.h"

@interface LoginHomeViewController () {
    
    IBOutlet UILabel *forgotPasswordLabel;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UILabel *signupLabel;
    IBOutlet UIImageView *usernameIcon;
    IBOutlet UIImageView *passwordIcon;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *signupButton;
}

- (IBAction)onClickLogin:(id)sender;
- (IBAction)onClickFacebookLogin:(id)sender;
- (IBAction)onClickForgottenPassword:(id)sender;
- (IBAction)onClickSignup:(id)sender;

@end

@implementation LoginHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self setupLabels];
    [self setupImageViews];
    [self setupButtons];
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

- (IBAction)onClickLogin:(id)sender {
    [self.view endEditing:YES];
    
    if ([InputValidator validateLoginInput:usernameField.text password:passwordField.text viewController:self]) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        [GTUserManager loginWithUsername:usernameField.text password:passwordField.text successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
            });
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED)
                [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"The username or password are incorrect." closeButtonTitle:@"OK" duration:0.0f];
            else
                [[SCLAlertView new] showError:self title:APP_NAME subTitle:response.message closeButtonTitle:@"OK" duration:0.0f];
        }];
    }
}

- (IBAction)onClickFacebookLogin:(id)sender {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [self facebookSessionStateChange:session state:state error:error];
     }];
}

- (IBAction)onClickForgottenPassword:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_RESET_PASSWORD" sender:nil];
}

- (IBAction)onClickSignup:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_SIGN_UP" sender:nil];
}

#pragma mark - Facebook login

- (void)facebookSessionStateChange:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // If the session was opened successfully.
    if (!error && state == FBSessionStateOpen){
        [self doProcessFacebookSessionOpened];
        
        return;
    }
    
    [[LoadingViewManager getInstance] removeLoadingView];
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        // If the session is closed.
        [self doProcessFacebookSessionClosed];
    }
    
    if (error) {
        // Clear this token.
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)doProcessFacebookSessionOpened {
    // Fetch the user's Facebook ID.
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
         if (!error) {
             // 1. Check if the user exists.
             // 1.1 If they exist, proceed as usual.
             // 1.2 If they don't exist, ask them to pick a username.
             // 1.2.1 Once they pick the username, ask if they want to copy their avatar from the external source.
             // 1.2.1.1 If they don't, proceed as usual.
             // 1.2.1.2 If they do, download avatar from external source.
             // 1.2.1.2.1 Send avatar to server.
             // 1.2.1.2.2 Proceed as usual.
             
             // 1.
             NSString *externalId = [aUser objectForKey:@"id"];
             
             [GTUserManager verifyUserWithExternalId:externalId successBlock:^(GTResponseObject *response) {
                 // 1.1
                 [[LoadingViewManager getInstance] removeLoadingView];
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
                 });
             } failureBlock:^(GTResponseObject *response) {
                 [[LoadingViewManager getInstance] removeLoadingView];
                 
                 if (response.reason == NOT_FOUND) {
                     // 1.2
                     [self askUserForUsername:aUser];
                 }
                 else {
                     [FBSession.activeSession closeAndClearTokenInformation];
                     
                     [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"We couldn't process your request right now. Please try again." closeButtonTitle:@"OK" duration:0.0f];
                 }
             }];
         }
         else
             [[LoadingViewManager getInstance] removeLoadingView];
     }];
}

- (void)doProcessFacebookSessionClosed {
    // Ignore.
}

- (void)askUserForUsername:(NSDictionary<FBGraphUser> *)facebookuser {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    UITextField *nameField = [alert addTextField:@"Username"];
    
    [alert addButton:@"Done" actionBlock:^(void) {
        [self.view endEditing:YES];
        
        if (nameField.text.length <= 0) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert addButton:@"OK" actionBlock:^(void) {
                [self askUserForUsername:facebookuser];
            }];
            
            [alert showTitle:self title:APP_NAME subTitle:@"Please enter a valid username." style:Error closeButtonTitle:nil duration:0.0f];
        }
        else {
            NSString *externalId = [facebookuser objectForKey:@"id"];
            NSString *email = [facebookuser objectForKey:@"email"];
            NSString *firstName = [facebookuser objectForKey:@"first_name"];
            NSString *lastName = [facebookuser objectForKey:@"last_name"];

            [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
            
            [GTUserManager signupWithUsername:nameField.text password:nil email:email firstName:firstName lastName:lastName externalId:externalId successBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                // 1.2.1
                [self askUserForAvatar:facebookuser];
            } failureBlock:^(GTResponseObject *response) {
                [[LoadingViewManager getInstance] removeLoadingView];
                
                if (response.reason == ALREADY_EXISTS) {
                    SCLAlertView *alert = [[SCLAlertView alloc] init];
                    [alert addButton:@"OK" actionBlock:^(void) {
                        [self askUserForUsername:facebookuser];
                    }];
                    
                    [alert showTitle:self title:APP_NAME subTitle:@"This username or Facebook email have already been taken." style:Error closeButtonTitle:nil duration:0.0f];
                }
                else {
                    [FBSession.activeSession closeAndClearTokenInformation];
                    
                    [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"We couldn't process your request right now. Please try again." closeButtonTitle:@"OK" duration:0.0f];
                }
            }];
        }
    }];
    [alert addButton:@"Cancel" actionBlock:^{
        [FBSession.activeSession closeAndClearTokenInformation];
    }];
    
    [alert showEdit:self title:APP_NAME subTitle:@"Please choose your username." closeButtonTitle:nil duration:0.0f];
}

- (void)askUserForAvatar:(NSDictionary<FBGraphUser> *)facebookuser {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:@"Import" actionBlock:^(void) {
        // 1.2.1.2
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        NSString *userImageURL = [NSString stringWithFormat:APP_FACEBOOK_AVATAR_URL, [facebookuser objectID]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 1.2.1.2.1
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]];
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [GTUserManager editAvatarWithNewImage:image successBlock:^(GTResponseObject *response) {
                    // 1.2.1.2.2
                    [[LoadingViewManager getInstance] removeLoadingView];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
                    });
                } failureBlock:^(GTResponseObject *response) {
                    // 1.2.1.2.2
                    [[LoadingViewManager getInstance] removeLoadingView];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
                    });
                }];
            });
        });
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        // 1.2.1.1
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
        });
    }];
    
    [alert showTitle:self title:APP_NAME subTitle:@"Your profile is setup. Would you like to import your Facebook avatar?" style:Success closeButtonTitle:nil duration:0.0f];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 1)
        [passwordField becomeFirstResponder];
    else if (textField.tag == 2)
        [self onClickLogin:nil];
    
    return YES;
}

#pragma mark - Setup

- (void)setupLabels {
    NSString *title = signupLabel.text;
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:99 green:131 blue:151 alpha:1.0] range:[title rangeOfString:@"Sign Up"]];
    
    signupLabel.attributedText = attString;
    
    usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)setupImageViews {
    usernameIcon.image = [usernameIcon.image imageWithTint:[UIColor whiteColor]];
    passwordIcon.image = [passwordIcon.image imageWithTint:[UIColor whiteColor]];
    [facebookButton setImage:[facebookButton.imageView.image imageWithTint:[UIColor whiteColor]] forState:UIControlStateNormal];
}

- (void)setupButtons {
    [facebookButton setImage:[facebookButton.imageView.image imageWithTint:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    facebookButton.layer.cornerRadius = 3;
    signupButton.layer.cornerRadius = 3;
}

@end
