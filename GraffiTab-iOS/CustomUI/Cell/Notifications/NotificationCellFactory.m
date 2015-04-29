//
//  NotificationCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationCellFactory.h"

@implementation NotificationCellFactory

+ (NotificationCell *)createNotificationCellForNotification:(Notification *)notification tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NotificationType type = notification.type;
    NotificationCell *cell;
    
    if (type == WELCOME)
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationWelcomeCell" forIndexPath:indexPath];
    else if (type == MENTION)
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationMentionCell" forIndexPath:indexPath];
    else if (type == LIKE)
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationLikeCell" forIndexPath:indexPath];
    else if (type == FOLLOW)
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationFollowCell" forIndexPath:indexPath];
    else if (type == COMMENT)
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCommentCell" forIndexPath:indexPath];
    
    cell.item = notification;
    
    return cell;
}

@end
