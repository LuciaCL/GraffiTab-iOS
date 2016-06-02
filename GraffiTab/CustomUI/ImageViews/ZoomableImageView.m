//
//  ZoomableImageView.m
//  MEDImagingCaseiPhone
//
//  Created by Georgi Christov on 12/6/13.
//  Copyright (c) 2013 Proxiad. All rights reserved.
//

#import "ZoomableImageView.h"

@interface ZoomableImageView () {
    
}

@end

@implementation ZoomableImageView

@synthesize scrollView;
@synthesize delegate;
@synthesize minZoomScale;
@synthesize maxZoomScale;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code.
        [self baseInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Initialization code.
        [self baseInit];
    }
    
    return self;
}

- (void)dealloc {
    [imageView removeFromSuperview];
    imageView = nil;
    [scrollView removeFromSuperview];
    scrollView = nil;
}

- (void)onTapImageView {
    if (scrollView.zoomScale != minZoomScale) {
        [scrollView setZoomScale:minZoomScale animated:YES];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(didTapImageView:)])
        [delegate didTapImageView:self];
}

- (void)setImage:(UIImage *)i {
    scrollView.zoomScale = minZoomScale;
    imageView.image = i;
}

- (void)setMinZoomScale:(CGFloat)ms {
    self.minZoomScale = ms;
    
    if (minZoomScale < 1)
        minZoomScale = 1.0;
    
    scrollView.minimumZoomScale = minZoomScale;
}

- (void)setMaxZoomScale:(CGFloat)ms {
    self.maxZoomScale = ms;
    
    scrollView.maximumZoomScale = maxZoomScale;
}

- (void)baseInit {
    self.backgroundColor = [UIColor clearColor];
    
    minZoomScale = 1.0;
    maxZoomScale = 4.0;
    
    // Setup scroll view.
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    scrollView.minimumZoomScale = minZoomScale;
    scrollView.maximumZoomScale = maxZoomScale;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.canCancelContentTouches = NO;
    scrollView.clipsToBounds = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [scrollView setScrollEnabled:YES];
    
    // Setup image view.
    imageView = [[UIImageView alloc] init];
    [self setupImageView];
    
    [self addSubview:scrollView];
}

- (void)replaceImageView:(UIImageView *)view {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    self.imageView = view;
    [self setupImageView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                   scrollView.contentSize.height * 0.5 + offsetY);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didZoomImageView:)])
        [self.delegate didZoomImageView:self];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark - Setup

- (void)setupImageView {
    imageView.frame = scrollView.bounds;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImageView)];
    [imageView addGestureRecognizer:tgr];
    tgr = nil;
    
    [scrollView addSubview:imageView];
}

@end
