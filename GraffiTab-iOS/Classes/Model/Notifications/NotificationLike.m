//
//  NotificationLike.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationLike.h"

@implementation NotificationLike

- (id)initFromJson:(NSDictionary *)json {
    self = [super initFromJson:json];
    
    if (self) {
        self.item = [StreamableFactory createStreamableFromJson:json[JSON_NOTIFICATION_LIKE_ITEM]];
        self.liker = [[Person alloc] initFromJson:json[JSON_NOTIFICATION_LIKE_LIKER]];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super asDictionary]];
    
    json[JSON_NOTIFICATION_LIKE_ITEM] = self.item.asDictionary;
    json[JSON_NOTIFICATION_LIKE_LIKER] = self.liker.asDictionary;
    
    return json;
}

@end
