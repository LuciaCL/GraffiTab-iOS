//
//  NSString+HTMLStrip.m
//  EZtrans
//
//  Created by Georgi Christov on 1/9/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import "NSString+HTMLStrip.h"

@implementation NSString (HTMLStrip)

- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    
    return s;
}

- (NSString *)stringByStrippingWhitespaceAndNewline {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
