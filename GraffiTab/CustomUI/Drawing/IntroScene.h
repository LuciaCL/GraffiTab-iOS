//
//  IntroScene.h
//  Smooth Drawing - v3
//
//  Created by Richard Groves on 02/06/2014.
//  SEE LICENSE
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "LineDrawer.h"

@interface IntroScene : CCScene

@property (nonatomic, strong) LineDrawer *canvas;

- (id)init:(CGRect)frame;
- (void)reframeViews:(CGSize)size;

@end