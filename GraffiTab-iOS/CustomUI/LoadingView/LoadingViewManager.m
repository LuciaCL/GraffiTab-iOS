//
//  LoadingViewManager.m
//  DigiGraff
//
//  Created by Georgi Christov on 7/1/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import "LoadingViewManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingViewManager

static LoadingViewManager *sharedInstance = nil;

+ (LoadingViewManager *)getInstance {
    @synchronized( sharedInstance ) {
		if ( sharedInstance == nil )
			sharedInstance = [[LoadingViewManager alloc] init];
	}
    
	return sharedInstance;
}

- (void)dealloc {
    theView = nil;
    theHUD = nil;
}

- (BOOL)isWorking {
    return isProcessing;
}

- (void)addFullLoadingToView:(UIView *)superView withMessage:(NSString *)msg {
    if ( theView != nil ) {
        [theView removeFromSuperview];
        theView = nil;
    }
    
    theView = [[LoadingView alloc] initIntoView:superView withMessage:msg];
    
    [superView addSubview:theView];
    
    // Create a new animation.
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    
    isProcessing = YES;
}

- (void)removeFullLoadingView {
    isProcessing = NO;
    
    if ( theView != nil ) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [[[theView superview] layer] addAnimation:animation forKey:@"layerAnimation"];
        
        [theView removeFromSuperview];
        theView = nil;
    }
}

- (void)addLoadingToView:(UIView *)superView withMessage:(NSString *)msg {
    if ( theHUD != nil ) {
        [theHUD hide:YES];
        theHUD = nil;
    }
    
    theHUD = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    theHUD.mode = MBProgressHUDModeIndeterminate;
    theHUD.labelText = msg;
    theHUD.removeFromSuperViewOnHide = YES;
    
    isProcessing = YES;
}

- (void)removeLoadingView {
    isProcessing = NO;
    
    if ( theHUD != nil ) {
        [theHUD hide:YES];
        theHUD = nil;
    }
}

@end
