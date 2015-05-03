//
//  NotificationsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : BackButtonViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isModal;

@end
