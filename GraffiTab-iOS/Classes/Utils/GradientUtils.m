//
//  GradientUtils.m
//  DigiGraff
//
//  Created by Georgi Christov on 12/26/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import "GradientUtils.h"

@implementation GradientUtils

+ (CALayer *)setGradientBackgroundForView:(UIView *)v topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = v.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    [v.layer insertSublayer:gradient atIndex:0];
    
    return gradient;
}

@end
