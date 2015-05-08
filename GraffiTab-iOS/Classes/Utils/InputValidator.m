//
//  InputValidator.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "InputValidator.h"

@implementation InputValidator

+ (BOOL)validateResetPasswordInput:(NSString *)email viewController:(UIViewController *)vc {
    if (email.length <= 0)
        return NO;
    
    if (![self validateEmail:email]) {
        [Utils showMessage:APP_NAME message:@"This email address is not valid."];
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateSignupInput:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword email:(NSString *)email firstname:(NSString *)firstname lastname:(NSString *)lastname viewController:(UIViewController *)vc {
    if (firstname.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your first name."];
        
        return NO;
    }
    if (lastname.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your last name."];
        
        return NO;
    }
    if (username.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter a username."];
        
        return NO;
    }
    if (password.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter a password."];
        
        return NO;
    }
    if (confirmPassword.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please confirm your password."];
        
        return NO;
    }
    if (email.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your email address."];
        
        return NO;
    }
    
    if (![password isEqualToString:confirmPassword]) {
        [Utils showMessage:APP_NAME message:@"Your passwords do not match."];
        
        return NO;
    }
    
    if (![self validateEmail:email]) {
        [Utils showMessage:APP_NAME message:@"This email address is not valid."];
        
        return NO;
    }
    
    if (username.length <= 2) {
        [Utils showMessage:APP_NAME message:@"Your username must be at least 3 characters long."];
        
        return NO;
    }
    if (password.length <= 3) {
        [Utils showMessage:APP_NAME message:@"Your password must be at least 4 characters long."];
        
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateLoginInput:(NSString *)username password:(NSString *)password viewController:(UIViewController *)vc {
    if (username.length <= 0)
        return NO;
    if (password.length <= 0)
        return NO;
    
    return YES;
}

+ (BOOL)validateProfileEditInput:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email about:(NSString *)about website:(NSString *)website viewController:(UIViewController *)vc {
    if (firstName.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your first name."];
        
        return NO;
    }
    if (lastName.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your last name."];

        return NO;
    }
    if (email.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your email."];
        
        return NO;
    }
    
    if (![self validateEmail:email]) {
        [Utils showMessage:APP_NAME message:@"This email address is not valid."];

        return NO;
    }
    
    return YES;
}

+ (BOOL)validateEditPasswordInput:(NSString *)password newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword viewController:(UIViewController *)vc {
    if (password.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your password."];

        return NO;
    }
    if (newPassword.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter your new password."];

        return NO;
    }
    if (confirmPassword.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please confirm your new password."];

        return NO;
    }
    
    if (![newPassword isEqualToString:confirmPassword]) {
        [Utils showMessage:APP_NAME message:@"Your passwords do not match."];

        return NO;
    }
    
    if (newPassword.length <= 3) {
        [Utils showMessage:APP_NAME message:@"Your new password must have at least 4 characters."];

        return NO;
    }
    
    return YES;
}

+ (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

@end
