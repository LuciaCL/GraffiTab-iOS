//
//  Comment.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.commentId = [json[JSON_COMMENT_ID] longValue];
        self.itemId = [json[JSON_COMMENT_ITEMID] longValue];
        self.user = [[Person alloc] initFromJson:json[JSON_COMMENT_USER]];
        self.text = json[JSON_COMMENT_TEXT];
        self.date = [NSDate dateWithTimeIntervalSince1970:[json[JSON_COMMENT_DATE] longValue] / 1000];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_COMMENT_ID] = @(self.commentId);
    json[JSON_COMMENT_ITEMID] = @(self.itemId);
    json[JSON_COMMENT_USER] = self.user.asDictionary;
    json[JSON_COMMENT_TEXT] = self.text;
    json[JSON_COMMENT_DATE] = @(self.date.timeIntervalSince1970);
    
    return json;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Comment *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.commentId != aWidget.commentId)
        return NO;
    return YES;
}

@end
