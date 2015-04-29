//
//  Notification.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    COMMENT,
    FOLLOW,
    LIKE,
    MENTION,
    WELCOME,
    CUSTOM_TYPING_ON,
    CUSTOM_TYPING_OFF,
    CUSTOM_MESSAGE
} NotificationType;

#define NOTIFICATION_TYPE_LIST @[@"COMMENT", @"FOLLOW", @"LIKE", @"MENTION", @"WELCOME", @"CUSTOM_TYPING_ON", @"CUSTOM_TYPING_OFF", @"CUSTOM_MESSAGE"]

#define NotificationType(str) (NotificationType)[NOTIFICATION_TYPE_LIST indexOfObject:str]

@interface Notification : NSObject <JSONSerializable>

@property (nonatomic, assign) long notificationId;
@property (nonatomic, strong) Person *user;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NotificationType type;

- (id)initFromJson:(NSDictionary *)json;

@end
