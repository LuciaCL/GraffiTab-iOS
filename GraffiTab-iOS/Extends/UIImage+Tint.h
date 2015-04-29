//
//  UIImage+Tint.h
//  EZtrans
//
//  Created by Georgi Christov on 1/21/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Tint)

- (UIImage *)imageWithTint:(UIColor *)c;
- (UIImage *)colorizeImagWithColor:(UIColor *)color;

@end
