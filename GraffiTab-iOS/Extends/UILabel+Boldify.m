//
//  UILabel+Boldify.m
//  MOTM-iOS
//
//  Created by Georgi Christov on 29/08/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import "UILabel+Boldify.h"

@implementation UILabel (Boldify)

- (void)boldSubstring:(NSString *)substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

- (void)boldRange:(NSRange)range {
    if (![self respondsToSelector:@selector(setAttributedText:)])
        return;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}

@end
