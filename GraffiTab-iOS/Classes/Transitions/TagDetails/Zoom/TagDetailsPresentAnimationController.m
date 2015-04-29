//
//  TagDetailsPresentAnimationController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsPresentAnimationController.h"
#import "TagDetailsViewController.h"

@implementation TagDetailsPresentAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get controllers.
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];

    // Setup background view.
    UIView *darkView = [[UIView alloc] initWithFrame:containerView.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 1;
    darkView.alpha = 0.0;
    [containerView addSubview:darkView];
    
    // Setup toViewController frame.
    UINavigationController *nav = (UINavigationController *) toViewController;
    TagDetailsViewController *vc = (TagDetailsViewController *) nav.viewControllers.firstObject;
    
    toViewController.view.frame = vc.originFrame;
    toViewController.view.alpha = 0.0;
    [containerView addSubview:toViewController.view];
    
    int targetWidth = containerView.frame.size.width - 40;
    int targetHeight = containerView.frame.size.height - 60;
    
    // Perform animations.
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration / 2.0 animations:^{
        toViewController.view.alpha = 1.0;
        toViewController.view.frame = CGRectMake(containerView.frame.size.width/2 - targetWidth/2, containerView.frame.size.height/2 - targetHeight/2, targetWidth, targetHeight);
        
        darkView.alpha = 0.8;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
