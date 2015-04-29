//
//  NSString+HTMLStrip.h
//  EZtrans
//
//  Created by Georgi Christov on 1/9/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLStrip)

- (NSString *)stringByStrippingHTML;
- (NSString *)stringByStrippingWhitespaceAndNewline;

@end
