//
//  Streamable.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Streamable.h"

@implementation Streamable

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.streamableId = [json[JSON_STREAMABLE_ID] longValue];
        self.user = [[Person alloc] initFromJson:json[JSON_STREAMABLE_USER]];
        self.date = [NSDate dateWithTimeIntervalSince1970:[json[JSON_STREAMABLE_DATE] longValue] / 1000];
        self.type = StreamableType(json[JSON_STREAMABLE_TYPE]);
        self.isPrivate = [json[JSON_STREAMABLE_ISPRIVATE] boolValue];
        self.isFlagged = [json[JSON_STREAMABLE_ISFLAGGED] boolValue];
        self.likesCount = [json[JSON_STREAMABLE_LIKES_COUNT] intValue];
        self.commentsCount = [json[JSON_STREAMABLE_COMMENTS_COUNT] intValue];
        self.isLiked = [json[JSON_STREAMABLE_ISLIKED] boolValue];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_STREAMABLE_ID] = @(self.streamableId);
    json[JSON_STREAMABLE_USER] = self.user.asDictionary;
    json[JSON_STREAMABLE_DATE] = @(self.date.timeIntervalSince1970);
    json[JSON_STREAMABLE_TYPE] = STREAMABLE_TYPE_LIST[self.type];
    json[JSON_STREAMABLE_ISPRIVATE] = @(self.isPrivate);
    json[JSON_STREAMABLE_ISFLAGGED] = @(self.isFlagged);
    json[JSON_STREAMABLE_LIKES_COUNT] = @(self.likesCount);
    json[JSON_STREAMABLE_COMMENTS_COUNT] = @(self.commentsCount);
    json[JSON_STREAMABLE_ISLIKED] = @(self.isLiked);
    
    return json;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Streamable *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.streamableId != aWidget.streamableId)
        return NO;
    return YES;
}

@end
