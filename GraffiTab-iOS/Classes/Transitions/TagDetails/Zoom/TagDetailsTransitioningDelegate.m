//
//  TagDetailsTransitioningDelegate.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TagDetailsTransitioningDelegate.h"
#import "TagDetailsPresentAnimationController.h"
#import "TagDetailsDismissAnimationController.h"

@implementation TagDetailsTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[TagDetailsPresentAnimationController alloc] init];
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[TagDetailsDismissAnimationController alloc] init];
}

@end
