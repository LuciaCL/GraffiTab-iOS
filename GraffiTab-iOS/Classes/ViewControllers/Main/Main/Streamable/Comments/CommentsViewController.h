//
//  CommentsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 28/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TweetProtocol.h"
#import "WYPopoverController.h"

@interface CommentsViewController : BackButtonSLKTextViewController <TweetProtocol>

@property (nonatomic, assign) GTStreamable *item;
@property (nonatomic, assign) BOOL embedded;
@property (nonatomic, strong) WYPopoverController *parentPopover;
@property (nonatomic, strong) UIViewController *parent;

@end
