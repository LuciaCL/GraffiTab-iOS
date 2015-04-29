//
//  Utils.m
//  MOTM-iOS
//
//  Created by Georgi Christov on 28/08/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)urlDecode:(NSString *)s {
    NSString *result = [s stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}

+ (NSString *)urlEncode:(NSString *)s usingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)s, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding)));
}

+ (void)logoutUserAndShowLoginController {
    [[Settings getInstance] setUser:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [Utils clearCookies];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_OUT object:nil];
    });
}

+ (void)clearCookies {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies])
        [storage deleteCookie:cookie];
    
    [CookieManager saveCookies];
}

+ (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+ (CGFloat)deviceKeyboardHeight {
    if ( IS_IPAD )
        return (IS_LANDSCAPE ? KEYBOARD_HEIGHT_IPAD_L : KEYBOARD_HEIGHT_IPAD_P);
    else
        return (IS_LANDSCAPE ? KEYBOARD_HEIGHT_IPHONE_L : KEYBOARD_HEIGHT_IPHONE_P);
}

+ (void)openUrl:(NSString *)url {
    NSURL *myURL;
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
        myURL = [NSURL URLWithString:url];
    else
        myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]];
    
    [[UIApplication sharedApplication] openURL:myURL];
}

+ (void)showView:(UIView *)v {
    [UIView animateWithDuration:0.5
                     animations:^ {
                         v.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {}
     ];
}

+ (void)hideView:(UIView *)v {
    [UIView animateWithDuration:0.5
                     animations:^ {
                         v.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {}
     ];
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (void)applyShadowEffectToView:(UIView *)i {
    CALayer *layer = i.layer;
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:0.1];
    [layer setShadowOffset:CGSizeMake(1, 1)];
    [layer setShadowRadius:2.0];
    [layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:i.bounds cornerRadius:2.0] CGPath]];
    [i setClipsToBounds:NO];
}

@end
