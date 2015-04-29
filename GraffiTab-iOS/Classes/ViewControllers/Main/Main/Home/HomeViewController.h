//
//  HomeViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

@interface HomeViewController : BackButtonTwitterPagerViewController <SlideNavigationControllerDelegate>

@property (nonatomic, assign) int unseenNotificationsCount;
@property (nonatomic, assign) int unseenMessagesCount;

- (void)updateUnseenNotificationsBadge;

@end
