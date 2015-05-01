//
//  TagDetailsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 30/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomableNormalImageView.h"

@interface TagDetailsViewController : UIViewController <ZoomableNormalImageViewDelegate>

@property (nonatomic, assign) GTStreamableTag *item;
@property (nonatomic, assign) CGRect originFrame;

@end
