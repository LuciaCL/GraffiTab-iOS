//
//  IntroScene.m
//  Smooth Drawing - v3
//

#import "IntroScene.h"

@implementation IntroScene

- (id)init:(CGRect)frame {
	self = [super init];

    if (self) {
		_canvas = [[LineDrawer alloc] init];
        [self reframeViews:frame.size];
		[self addChild:_canvas];
	}
	
    return self;
}

- (void)reframeViews:(CGSize)size {
    self.contentSize = size;
    self.position = CGPointZero;
    self.anchorPoint = CGPointZero;
    
    _canvas.contentSize = size;
    _canvas.position = CGPointZero;
    _canvas.anchorPoint = CGPointZero;
    [_canvas reframeViews:size];
}

@end