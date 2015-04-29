//
//  UILabel+Boldify.h
//  MOTM-iOS
//
//  Created by Georgi Christov on 29/08/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Boldify)

- (void)boldSubstring:(NSString *)substring;
- (void)boldRange:(NSRange)range;

@end
