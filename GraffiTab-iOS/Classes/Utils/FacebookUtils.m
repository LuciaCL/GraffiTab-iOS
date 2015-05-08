//
//  FacebookUtils.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "FacebookUtils.h"

static FBSessionStateHandler oldHandler;

@implementation FacebookUtils

+ (void)connectFacebook {
    FBSessionStateHandler handler = [self FBSessionStateHandler];
    [FBSession.activeSession setStateChangeHandler:handler];
    
    [[LoadingViewManager getInstance] addLoadingToView:[SlideNavigationController sharedInstance].view withMessage:@"Processing"];

    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                       allowLoginUI:YES
                                  completionHandler:handler];
}

#pragma mark - Facebook login

+ (void)facebookSessionStateChange:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    // If the session was opened successfully.
    if (!error && state == FBSessionStateOpen) {
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

+ (void)doProcessFacebookSessionOpened {
    // Fetch the user's Facebook ID.
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
         if (!error) {
             // 1. Check if the user exists.
             // 1.1 If they exist, proceed as usual.
             // 1.2 If they don't exist, add their external id to their profile.
             
             // 1.
             NSString *externalId = [aUser objectForKey:@"id"];
             
             [GTUserManager linkExternalId:externalId successBlock:^(GTResponseObject *response) {
                 [[LoadingViewManager getInstance] removeLoadingView];
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [Utils showMessage:APP_NAME message:@"Your profile is now linked with Facebook and you can use it to log in and out."];
                 });
             } failureBlock:^(GTResponseObject *response) {
                 [[LoadingViewManager getInstance] removeLoadingView];
                 
                 [FBSession.activeSession closeAndClearTokenInformation];
                 
                 if (response.reason == ALREADY_EXISTS)
                     [Utils showMessage:APP_NAME message:@"This Facebook account is already linked to another profile. Please choose a different account."];
                 else
                     [Utils showMessage:APP_NAME message:@"We couldn't process your request right now. Please try again."];
             }];
         }
         else
             [[LoadingViewManager getInstance] removeLoadingView];
     }];
}

+ (void)doProcessFacebookSessionClosed {
    // Ignore.
}

+ (FBSessionStateHandler)FBSessionStateHandler {
    __weak typeof(self) weakSelf = self;
    FBSessionStateHandler handler = ^(FBSession *session, FBSessionState state, NSError *error) {
        // Handler for session state changes
        // This method will be called EACH time the session state changes,
        // also for intermediate states and NOT just when the session open
        [weakSelf facebookSessionStateChange:session state:state error:error];
    };
    
    return handler;
}

@end
