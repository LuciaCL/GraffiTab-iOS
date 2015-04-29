//
//  TagDetailsBouncePresentAnimationController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsBouncePresentAnimationController.h"

@implementation TagDetailsBouncePresentAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get controllers.
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    // Setup background view.
    UIView *darkView = [[UIView alloc] initWithFrame:containerView.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 1;
    darkView.alpha = 0.0;
    [containerView addSubview:darkView];
    
    toViewController.view.frame = CGRectMake(0, 0, containerView.bounds.size.width - 40, containerView.bounds.size.height - 60);
    toViewController.view.center = fromViewController.view.center;
    
    [containerView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0.0;
    toViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration / 2.0 animations:^{
        toViewController.view.alpha = 1.0;
        darkView.alpha = 0.8;
    }];
    
    CGFloat damping = 0.55;
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
