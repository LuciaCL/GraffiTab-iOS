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
		_canvas.contentSize = CGSizeMake(frame.size.width, frame.size.height);
		_canvas.position = CGPointZero;
		_canvas.anchorPoint = CGPointZero;
		[self addChild:_canvas];
	}
	
    return self;
}

@end