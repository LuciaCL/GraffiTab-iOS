//
//  LikesViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "USRViewController.h"
#import "WYPopoverController.h"

@interface LikesViewController : USRViewController

@property (nonatomic, assign) GTStreamable *item;
@property (nonatomic, assign) BOOL embedded;
@property (nonatomic, strong) WYPopoverController *parentPopover;

@end
