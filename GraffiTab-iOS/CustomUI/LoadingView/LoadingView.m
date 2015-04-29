//
//  LoadingView.m
//  DigiGraff
//
//  Created by Georgi Christov on 7/1/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initIntoView:(UIView *)superView withMessage:(NSString *)msg {
	// Create a new view with the same frame size as the superView
	self = [super initWithFrame:superView.bounds];
	
    // If something's gone wrong, abort!
	if ( self != nil ) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        // Create a new image view, from the image made by our gradient method.
        UIImageView *background = [[UIImageView alloc] initWithImage:[self addBackground]];
        background.alpha = 0.7;
        [self addSubview:background];
        background = nil;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, superView.center.y - 25, superView.frame.size.width, 30.0)];
        label.text = msg;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        label = nil;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        indicator.center = superView.center;
        indicator.frame = CGRectMake( indicator.frame.origin.x, indicator.frame.origin.y + 25, indicator.frame.size.width, indicator.frame.size.height);
        indicator.hidesWhenStopped = YES;
        [indicator startAnimating];
        [self addSubview:indicator];
        indicator = nil;
    }
    
    return self;
}

- (UIImage *)addBackground{
	// Create an image context (think of this as a canvas for our masterpiece) the same size as the view.
    UIGraphicsBeginImageContextWithOptions( self.bounds.size, YES, 1 );
    
	// Our gradient only has two locations - start and finish. More complex gradients might have more colours.
    size_t num_locations = 2;
    
	// The location of the colors is at the start and end.
    CGFloat locations[2] = { 0.0, 1.0 };
    
	// These are the colors! That's two RBGA values.
    CGFloat components[8] = {
        0.4,0.4,0.4, 0.8,
        0.1,0.1,0.1, 0.5 };
    
	// Create a color space.
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
    
	// Create a gradient with the values we've set up.
    CGGradientRef myGradient = CGGradientCreateWithColorComponents( myColorspace, components, locations, num_locations );
    
	// Set the radius to a nice size, 80% of the width. You can adjust this.
    float myRadius = (self.bounds.size.width * .8 ) / 2;
    
	// Now we draw the gradient into the context. Think painting onto the canvas.
    CGContextDrawRadialGradient( UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation );
    
	// Rip the 'canvas' into a UIImage object.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	// And release memory
    CGColorSpaceRelease( myColorspace );
    CGGradientRelease( myGradient );
    UIGraphicsEndImageContext();
	
    return image;
}

- (void)dealloc {
    NSLog(@"LoadingView dealloc");
}

@end
