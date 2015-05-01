//
//  AppDelegate.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "MyLocationManager.h"
#import "MessagesViewController.h"
#import "NotificationsViewController.h"
#import "UIWindow+PazLabs.h"
#import "ConversationsViewController.h"

@interface AppDelegate () {
    
    NSString *activeStoryboardName;
    FBSessionStateHandler handler;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:NOTIFICATION_LOG_IN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:NOTIFICATION_LOG_OUT object:nil];
    
    [self setupStatusBar];
    [self setupCache];
    [self setupFacebookHandler];
    
    // Initialize the location manager.
    [MyLocationManager sharedInstance];
    
    // Clear app badge.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self checkLoginStatus];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [GTLifecycleManager applicationWillResignActive];
    
    [[MyLocationManager sharedInstance] stopLocationUpdates];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    [GTLifecycleManager applicationDidBecomeActive];
    
    [[MyLocationManager sharedInstance] startLocationUpdates];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark - Notifications

- (void)registerPushNotifications {
    if (IS_IOS8_AND_UP) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    [GTLifecycleManager setToken:hexToken];
    
    [GTDeviceManager registerDeviceWithToken:hexToken successBlock:^(GTResponseObject *response) {
        NSLog(@"Token registered");
    } failureBlock:^(GTResponseObject *response) {
        NSLog(@"Failed to register token");
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (app.applicationState == UIApplicationStateActive) {
        NotificationType type = NotificationType(userInfo[@"type"]);
        
        switch (type) {
            case COMMENT:
            case FOLLOW:
            case LIKE:
            case MENTION:
            case WELCOME: {
                break;
            }
            case CUSTOM_MESSAGE: {
                UIViewController *vc = [[UIApplication sharedApplication].keyWindow visibleViewController];
                
                if ([vc isKindOfClass:[MessagesViewController class]])
                    [((MessagesViewController *) vc) processMessageNotification:userInfo];
                else if ([vc isKindOfClass:[ConversationsViewController class]])
                    [((ConversationsViewController *) vc) processMessageNotification:userInfo];
                    
                break;
            }
            case CUSTOM_TYPING_ON: {
                UIViewController *vc = [[UIApplication sharedApplication].keyWindow visibleViewController];
                
                if ([vc isKindOfClass:[MessagesViewController class]])
                    [((MessagesViewController *) vc) processShowTypingIndicatorNotification:userInfo];
                
                break;
            }
            case CUSTOM_TYPING_OFF: {
                UIViewController *vc = [[UIApplication sharedApplication].keyWindow visibleViewController];
                
                if ([vc isKindOfClass:[MessagesViewController class]])
                    [((MessagesViewController *) vc) processHideTypingIndicatorNotification:userInfo];
                
                break;
            }
        }
    }
}

#pragma mark - Login

- (void)userDidLogin {
    // Change handler to be the application.
    [FBSession.activeSession setStateChangeHandler:handler];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self showStoryboardWithName:@"MainStoryboard" options:UIViewAnimationOptionTransitionCrossDissolve duration:0.7];
    
    // Register for push notifications.
    [self registerPushNotifications];
}

- (void)userDidLogout {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    // Clear this token
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [self showStoryboardWithName:@"LoginStoryboard" options:UIViewAnimationOptionTransitionCrossDissolve duration:0.7];
}

- (void)checkLoginStatus {
    [GTUserManager checkLoginStatusWithSuccessBlock:^(GTResponseObject *response) {
        [self checkLocalLoginStatus];
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == NETWORK)
            [self checkLocalLoginStatus];
        else {
            [GTLifecycleManager setUser:nil];
            
            [self showStoryboardWithName:@"LoginStoryboard" options:UIViewAnimationOptionTransitionCrossDissolve duration:0.7];
        }
    }];
}

- (void)checkLocalLoginStatus {
    // Check for a cached Facebook session. This means that the user has logged in with Facebook before.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:handler];
    }
    else { // No Facebook session, so check if the user has logged in at all.
        if ([GTLifecycleManager isLoggedIn])
            [self userDidLogin];
        else
            [self showStoryboardWithName:@"LoginStoryboard" options:UIViewAnimationOptionTransitionCrossDissolve duration:0.7];
    }
}

- (void)facebookSessionStateChange:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // If the session was opened successfully.
    if (!error && state == FBSessionStateOpen){
        [self doProcessFacebookSessionOpened];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        // If the session is closed.
        [self doProcessFacebookSessionClosed];
    }
    
    // Handle errors
    if (error){
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)doProcessFacebookSessionOpened {
    [self userDidLogin];
}

- (void)doProcessFacebookSessionClosed {
    [self showStoryboardWithName:@"LoginStoryboard" options:UIViewAnimationOptionTransitionCrossDissolve duration:0.7];
}

#pragma mark - Animations

- (void)showStoryboardWithName:(NSString *)name options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration {
    if (IS_IPAD)
        name = [NSString stringWithFormat:@"%@_ipad", name];
    
    if ([activeStoryboardName isEqualToString:name])
        return;
    
    activeStoryboardName = name;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *root = [storyboard instantiateInitialViewController];
    
    if ([name rangeOfString:@"Main"].location != NSNotFound) {
        UINavigationController *leftMenu = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        [SlideNavigationController sharedInstance].leftMenu = leftMenu;
        
        id <SlideNavigationContorllerAnimator> revealAnimator = [[SlideNavigationContorllerAnimatorSlide alloc] init];
        [SlideNavigationController sharedInstance].menuRevealAnimator = revealAnimator;
    }
    
    [self animateViewControllerSwitch:root options:options duration:duration];
}

- (void)animateViewControllerSwitch:(UIViewController *)vc options:(UIViewAnimationOptions)options duration:(NSTimeInterval)duration {
    [UIView
     transitionWithView:self.window
     duration:duration
     options:options
     animations:^(void) {
         BOOL oldState = [UIView areAnimationsEnabled];
         [UIView setAnimationsEnabled:NO];
         self.window.rootViewController = vc;
         [UIView setAnimationsEnabled:oldState];
     }
     completion:nil];
}

#pragma mark - Setup

- (void)setupStatusBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(COLOR_MAIN)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
}

- (void)setupCache {
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:300 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
}

- (void)setupFacebookHandler {
    __weak typeof(self) weakSelf = self;
    handler = ^(FBSession *session, FBSessionState state, NSError *error) {
        // Handler for session state changes
        // This method will be called EACH time the session state changes,
        // also for intermediate states and NOT just when the session open
        [weakSelf facebookSessionStateChange:session state:state error:error];
    };
}

@end
