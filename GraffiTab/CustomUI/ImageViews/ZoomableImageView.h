//
//  ZoomableImageView.h
//  MEDImagingCaseiPhone
//
//  Created by Georgi Christov on 12/6/13.
//  Copyright (c) 2013 Proxiad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZoomableImageView;

@protocol ZoomableImageViewDelegate <NSObject>

@optional
- (void)didTapImageView:(ZoomableImageView *)imageView;
- (void)didZoomImageView:(ZoomableImageView *)imageView;

@end

@interface ZoomableImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) IBOutlet id<ZoomableImageViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;

- (void)setImage:(UIImage *)i;

@end
