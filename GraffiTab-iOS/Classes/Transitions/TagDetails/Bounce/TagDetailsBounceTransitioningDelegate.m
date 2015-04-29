//
//  TagDetailsBounceTransitioningDelegate.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsBounceTransitioningDelegate.h"
#import "TagDetailsBouncePresentAnimationController.h"
#import "TagDetailsBounceDismissAnimationController.h"

@implementation TagDetailsBounceTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[TagDetailsBouncePresentAnimationController alloc] init];
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[TagDetailsBounceDismissAnimationController alloc] init];
}

@end
