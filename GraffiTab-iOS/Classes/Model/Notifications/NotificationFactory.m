//
//  NotificationFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationFactory.h"

@implementation NotificationFactory

+ (Notification *)createNotificationFromJson:(NSDictionary *)json {
    NotificationType type = NotificationType(json[JSON_NOTIFICATION_TYPE]);
    
    if (type == WELCOME)
        return [[NotificationWelcome alloc] initFromJson:json];
    else if (type == MENTION)
        return [[NotificationMention alloc] initFromJson:json];
    else if (type == LIKE)
        return [[NotificationLike alloc] initFromJson:json];
    else if (type == FOLLOW)
        return [[NotificationFollow alloc] initFromJson:json];
    else if (type == COMMENT)
        return [[NotificationComment alloc] initFromJson:json];
    else
        return [[Notification alloc] initFromJson:json];
}

@end
