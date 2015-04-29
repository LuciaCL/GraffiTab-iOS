//
//  GradientUtils.h
//  DigiGraff
//
//  Created by Georgi Christov on 12/26/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientUtils : NSObject

+ (CALayer *)setGradientBackgroundForView:(UIView *)v topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

@end
