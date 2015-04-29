//
//  LoadingViewManager.h
//  DigiGraff
//
//  Created by Georgi Christov on 7/1/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingView.h"
#import "MBProgressHUD.h"

@interface LoadingViewManager : NSObject {
    
    LoadingView *theView;
    MBProgressHUD *theHUD;
    
    BOOL isProcessing;
}

+ (LoadingViewManager *)getInstance;

- (void)addLoadingToView:(UIView *)view withMessage:(NSString *)msg;
- (void)removeLoadingView;
- (void)addFullLoadingToView:(UIView *)view withMessage:(NSString *)msg;
- (void)removeFullLoadingView;

- (BOOL)isWorking;

@end
