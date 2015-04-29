//
//  ClickableImage.m
//  MOTM-iOS
//
//  Created by Georgi Christov on 21/09/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import "ClickableImage.h"

@implementation ClickableImage

@synthesize delegate;
@synthesize normalImage;
@synthesize selectedImage;

- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize.
        [self baseInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialize.
        [self baseInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Initialize.
        [self baseInit];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.image = selectedImage;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.image = normalImage;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.image = normalImage;
    
    if (delegate && [delegate respondsToSelector:@selector(didClickImage:)])
        [delegate didClickImage:self];
}

- (void)baseInit {
    self.userInteractionEnabled = YES;
}

@end
