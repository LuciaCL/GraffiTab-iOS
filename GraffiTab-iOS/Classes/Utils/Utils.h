//
//  Utils.h
//  MOTM-iOS
//
//  Created by Georgi Christov on 28/08/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)urlDecode:(NSString *)s;
+ (NSString *)urlEncode:(NSString *)s usingEncoding:(NSStringEncoding)encoding;

+ (void)clearCookies;

+ (void)logoutUserAndShowLoginController;

+ (void)showMessage:(NSString *)title message:(NSString *)message;

+ (CGFloat)deviceKeyboardHeight;

+ (void)openUrl:(NSString *)url;

+ (void)showView:(UIView *)v;
+ (void)hideView:(UIView *)v;
+ (UIImage *)imageWithView:(UIView *)view;

+ (void)applyShadowEffectToView:(UIView *)i;

@end
