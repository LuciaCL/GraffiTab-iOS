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
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"This email address is not valid." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateSignupInput:(NSString *)username password:(NSString *)password confirmPassword:(NSString *)confirmPassword email:(NSString *)email firstname:(NSString *)firstname lastname:(NSString *)lastname viewController:(UIViewController *)vc {
    if (firstname.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your first name." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (lastname.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your last name." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (username.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter a username." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (password.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter a password." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (confirmPassword.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please confirm your password." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (email.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your email address." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (![password isEqualToString:confirmPassword]) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Your passwords do not match." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (![self validateEmail:email]) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"This email address is not valid." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (username.length <= 2) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Your username must have at least 3 characters." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (password.length <= 3) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Your password must have at least 4 characters." closeButtonTitle:@"OK" duration:0.0f];
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
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your first name." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (lastName.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your last name." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (email.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your email." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (![self validateEmail:email]) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"This email address is not valid." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    return YES;
}

+ (BOOL)validateEditPasswordInput:(NSString *)password newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword viewController:(UIViewController *)vc {
    if (password.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your password." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (newPassword.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please enter your new password." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    if (confirmPassword.length <= 0) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Please confirm your new password." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (![newPassword isEqualToString:confirmPassword]) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Your passwords do not match." closeButtonTitle:@"OK" duration:0.0f];
        return NO;
    }
    
    if (newPassword.length <= 3) {
        [[SCLAlertView new] showError:vc title:APP_NAME subTitle:@"Your new password must have at least 4 characters." closeButtonTitle:@"OK" duration:0.0f];
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
