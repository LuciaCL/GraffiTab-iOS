//
//  InputValidator.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputValidator : NSObject

+ (BOOL)validateResetPasswordInput:(NSString *)email viewController:(UIViewController *)vc;

+ (BOOL)validateSignupInput:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword email:(NSString *)email firstname:(NSString *)firstname lastname:(NSString *)lastname viewController:(UIViewController *)vc;

+ (BOOL)validateLoginInput:(NSString *)username password:(NSString *)password viewController:(UIViewController *)vc;

+ (BOOL)validateProfileEditInput:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email about:(NSString *)about website:(NSString *)website viewController:(UIViewController *)vc;
+ (BOOL)validateEditPasswordInput:(NSString *)password newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword viewController:(UIViewController *)vc;

@end
