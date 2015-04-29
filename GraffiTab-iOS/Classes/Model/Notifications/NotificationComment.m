//
//  NotificationComment.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationComment.h"

@implementation NotificationComment

- (id)initFromJson:(NSDictionary *)json {
    self = [super initFromJson:json];
    
    if (self) {
        self.commenter = [[Person alloc] initFromJson:json[JSON_NOTIFICATION_COMMENT_COMMENTER]];
        self.item = [StreamableFactory createStreamableFromJson:json[JSON_NOTIFICATION_COMMENT_ITEM]];
        self.comment = [[Comment alloc] initFromJson:json[JSON_NOTIFICATION_COMMENT_COMMENT]];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super asDictionary]];
    
    json[JSON_NOTIFICATION_COMMENT_COMMENTER] = self.commenter.asDictionary;
    json[JSON_NOTIFICATION_COMMENT_ITEM] = self.item.asDictionary;
    json[JSON_NOTIFICATION_COMMENT_COMMENT] = self.comment.asDictionary;
    
    return json;
}

@end
