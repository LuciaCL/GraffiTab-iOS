//
//  ClickableImage.h
//  MOTM-iOS
//
//  Created by Georgi Christov on 21/09/2014.
//  Copyright (c) 2014 Futurist Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClickableImageDelegate <NSObject>

@required
- (void)didClickImage:(UIImageView *)image;

@end

@interface ClickableImage : UIImageView

@property (nonatomic, assign) id <ClickableImageDelegate> delegate;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;

@end
