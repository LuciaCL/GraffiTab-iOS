//
//  NotificationCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationCellFactory.h"

@implementation NotificationCellFactory

+ (NotificationCell *)createNotificationCellForNotification:(GTNotification *)notification tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
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

+ (CGFloat)cellHeightForNotification:(GTNotification *)n tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if ([n isKindOfClass:[GTNotificationComment class]])
        return [NotificationCommentCell height];
    else if ([n isKindOfClass:[GTNotificationFollow class]])
        return [NotificationFollowCell height];
    else if ([n isKindOfClass:[GTNotificationLike class]])
        return [NotificationLikeCell height];
    else if ([n isKindOfClass:[GTNotificationMention class]])
        return [NotificationMentionCell height];
    else if ([n isKindOfClass:[GTNotificationWelcome class]])
        return [NotificationWelcomeCell height];
    else
        return [NotificationCell height];
}

@end
