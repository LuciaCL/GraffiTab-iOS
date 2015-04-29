//
//  TagDetailsDismissAnimationController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsDismissAnimationController.h"
#import "TagDetailsViewController.h"

@implementation TagDetailsDismissAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get controllers.
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    UIView *darkView = [containerView viewWithTag:1];
    
    // Setup toViewController frame.
    UINavigationController *nav = (UINavigationController *) fromViewController;
    TagDetailsViewController *vc = (TagDetailsViewController *) nav.viewControllers.firstObject;
    
    // Perform animations.
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         fromViewController.view.alpha = 0.0;
                         fromViewController.view.frame = vc.originFrame;
                         
                         darkView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
