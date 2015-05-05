//
//  ViewControllerUtils.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ViewControllerUtils.h"
#import "UserProfileViewController.h"
#import "TagDetailsViewController.h"
#import "SearchGraffitiViewController.h"
#import "UIWindow+PazLabs.h"
#import "GraffitiMapViewController.h"

@implementation ViewControllerUtils

+ (UIViewController *)getVisibleViewController {
    return [[UIApplication sharedApplication].keyWindow visibleViewController];
}

+ (void)showMapLocation:(CLLocation *)location fromViewController:(UIViewController *)controller {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    GraffitiMapViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"GraffitiMapViewController"];
    vc.location = location;
    vc.isModal = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [controller presentViewController:nav animated:YES completion:nil];
}

+ (void)showUserProfile:(GTPerson *)user fromViewController:(UIViewController *)controller {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    UserProfileViewController *prof = vc.viewControllers[0];
    prof.user = user;
    
    [controller presentViewController:vc animated:YES completion:nil];
}

+ (void)showSearchUserProfile:(NSString *)username fromViewController:(UIViewController *)controller {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    UserProfileViewController *prof = vc.viewControllers[0];
    prof.usernameToSearch = username;
    
    [controller presentViewController:vc animated:YES completion:nil];
}

+ (void)showSearchHashtag:(NSString *)hashtag fromViewController:(UIViewController *)controller {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    SearchGraffitiViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchGraffitiViewController"];
    [vc setSearchHashtag:hashtag];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [controller presentViewController:nav animated:YES completion:nil];
}

+ (void)showTag:(GTStreamableTag *)tag fromViewController:(UIViewController *)controller {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *tagDetailsNavigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagDetailsViewController"];
    
    TagDetailsViewController *vc = tagDetailsNavigation.viewControllers[0];
    vc.item = tag;
    
    int w = vc.view.frame.size.width - 40;
    int h = vc.view.frame.size.height - 60;
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    // Setup popup sheet.
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:tagDetailsNavigation];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(w, h);
    formSheet.shouldCenterVertically = YES;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

@end
