//
//  ZoomableImageView.h
//  MEDImagingCaseiPhone
//
//  Created by Georgi Christov on 12/6/13.
//  Copyright (c) 2013 Proxiad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZoomableNormalImageView;

@protocol ZoomableNormalImageViewDelegate <NSObject>

@optional
- (void)didTapImageView:(ZoomableNormalImageView *)imageView;
- (void)didZoomImageView:(ZoomableNormalImageView *)imageView;

@end

@interface ZoomableNormalImageView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) IBOutlet id<ZoomableNormalImageViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat minZoomScale;
@property (nonatomic, assign) CGFloat maxZoomScale;

- (void)setImage:(UIImage *)i;

@end
