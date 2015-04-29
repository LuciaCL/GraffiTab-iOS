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

@implementation ViewControllerUtils

+ (void)showUserProfile:(Person *)user fromViewController:(UIViewController *)controller {
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

+ (void)showTag:(StreamableTag *)tag fromViewController:(UIViewController *)controller originFrame:(CGRect)frame transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *tagDetailsNavigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"TagDetailsViewController"];
    tagDetailsNavigation.modalPresentationStyle = UIModalPresentationCustom;
    tagDetailsNavigation.transitioningDelegate = delegate;
    
    TagDetailsViewController *vc = tagDetailsNavigation.viewControllers[0];
    vc.item = tag;
    vc.originFrame = frame;
    
    [controller presentViewController:tagDetailsNavigation animated:YES completion:nil];
}

@end
