//
//  CCViewController.m
//  CCViewController
//
//  Created by Jerrod Putman on 2/7/12.
//  Copyright (c) 2012 Tiny Tim Games. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCViewController.h"
#import "IntroScene.h"

@interface CCViewController ()

@property (nonatomic) CCGLView *glView;

@end

@implementation CCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CCDirector *director = [CCDirector sharedDirector];

    // If the director's OpenGL view hasn't been set up yet, then we should create it now. If you would like to prevent this "lazy loading", you should initialize the director and set its view elsewhere in your code.
    if ([director isViewLoaded] == NO) {
        director.view = [self createDirectorGLView];
        [self didInitializeDirector];
    }
    else {
        director.view.frame = [self getCanvasFrame];
        [director.view setNeedsLayout];
        [director.view layoutIfNeeded];
    }

    director.delegate = self;
    
    // Add the director as a child view controller.
    [self addChildViewController:director];
    
    // Add the director's OpenGL view, and send it to the back of the view hierarchy so we can place UIKit elements on top of it.
    [self.targetView addSubview:director.view];
    [self.targetView sendSubviewToBack:director.view];
    
    // Ensure we fulfill all of our view controller containment requirements.
    [director didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Observe some notifications so we can properly instruct the director.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationSignificantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [[CCDirector sharedDirector] setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[CCDirector sharedDirector] purgeCachedData];
}

- (IBAction)close:(id)sender {
    [[CCDirector sharedDirector] purgeCachedData];
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification handlers

- (void)applicationWillResignActive:(NSNotification *)notification {
    [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[CCDirector sharedDirector] resume];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [[CCDirector sharedDirector] stopAnimation];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification {
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark - Director operations.

- (UIView *)targetView {
    return (self.canvasView ? self.canvasView : self.view);
}

- (CGRect)getCanvasFrame {
    [self.canvasView setNeedsLayout];
    [self.canvasView layoutIfNeeded];
    
    // Create a default OpenGL view.
    CGRect size = self.targetView.bounds;
    
    double oldWidth = size.size.width;
    double oldHeight = size.size.height;
    
    CGRect frame = CGRectMake(0, 0, oldWidth, oldHeight);
    return frame;
}

- (CCGLView *)createDirectorGLView {
    _glView = [CCGLView viewWithFrame:[self getCanvasFrame]
                          pixelFormat:kEAGLColorFormatRGB565
                          depthFormat:0
                   preserveBackbuffer:NO
                           sharegroup:nil
                        multiSampling:NO
                      numberOfSamples:0];
    
    return _glView;
}

- (void)didInitializeDirector {
    CCDirector *director = [CCDirector sharedDirector];
    
    // Set up some common director properties.
    [director setAnimationInterval:1.0f/1.0f];
}

@end
