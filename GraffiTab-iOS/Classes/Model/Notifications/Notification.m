//
//  Notification.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.notificationId = [json[JSON_NOTIFICATION_ID] longValue];
        self.user = [[Person alloc] initFromJson:json[JSON_NOTIFICATION_USER]];
        self.isRead = [json[JSON_NOTIFICATION_ISREAD] boolValue];
        self.date = [NSDate dateWithTimeIntervalSince1970:[json[JSON_NOTIFICATION_DATE] longValue] / 1000];
        self.type = NotificationType(json[JSON_NOTIFICATION_TYPE]);
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_NOTIFICATION_ID] = @(self.notificationId);
    json[JSON_NOTIFICATION_USER] = self.user.asDictionary;
    json[JSON_NOTIFICATION_ISREAD] = @(self.isRead);
    json[JSON_NOTIFICATION_DATE] = @(self.date.timeIntervalSince1970);
    json[JSON_NOTIFICATION_TYPE] = NOTIFICATION_TYPE_LIST[self.type];
    
    return json;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Notification *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.notificationId != aWidget.notificationId)
        return NO;
    return YES;
}

@end
