//
//  ViewControllerUtils.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewControllerUtils : NSObject

+ (UIViewController *)getVisibleViewController;

+ (void)showMapLocation:(CLLocation *)location fromViewController:(UIViewController *)controller;

+ (void)showUserProfile:(GTPerson *)user fromViewController:(UIViewController *)vc;
+ (void)showTag:(GTStreamableTag *)tag fromViewController:(UIViewController *)controller;

+ (void)showSearchUserProfile:(NSString *)username fromViewController:(UIViewController *)controller;
+ (void)showSearchHashtag:(NSString *)hashtag fromViewController:(UIViewController *)controller;

+ (void)showActivityStreamable:(NSMutableArray *)items fromViewController:(UIViewController *)controller;
+ (void)showActivityUser:(NSMutableArray *)items fromViewController:(UIViewController *)controller;

@end
