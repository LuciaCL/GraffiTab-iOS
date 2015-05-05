//
//  LoadingImageView.h
//  CG210
//
//  Created by Georgi Christov on 11/22/13.
//  Copyright (c) 2013 Proxiad. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingImageViewDelegate <NSObject>

@optional
- (void)didTapOnImage:(UIImageView *)i;

@end

@interface LoadingImageView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) IBOutlet id<LoadingImageViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL forceLoad;

- (void)loadImageWithUrl:(NSString *)url thumbnailUrl:(NSString *)url;
- (void)setImage:(UIImage *)i;

@end
