//
//  NotificationCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationCell.h"
#import "NotificationWelcomeCell.h"
#import "NotificationMentionCell.h"
#import "NotificationLikeCell.h"
#import "NotificationFollowCell.h"
#import "NotificationCommentCell.h"

@interface NotificationCellFactory : NSObject

+ (NotificationCell *)createNotificationCellForNotification:(GTNotification *)notification tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)cellHeightForNotification:(GTNotification *)notification tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
