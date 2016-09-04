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
        [self reframeViews:frame];
		[self addChild:_canvas];
	}
	
    return self;
}

- (void)reframeViews:(CGRect)frame {
    _canvas.contentSize = CGSizeMake(frame.size.width, frame.size.height);
    _canvas.position = CGPointZero;
    _canvas.anchorPoint = CGPointZero;
    [_canvas reframeViews:frame];
}

@end