//
//  NotificationsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 06/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonGUITabPagerViewController.h"

@interface NotificationsViewController : BackButtonGUITabPagerViewController <GUITabPagerDataSource, GUITabPagerDelegate>

@property (nonatomic, assign) BOOL isModal;

@end
