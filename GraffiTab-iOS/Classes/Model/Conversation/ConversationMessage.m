//
//  ConversationMessage.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "ConversationMessage.h"

@implementation ConversationMessage

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.messageId = [json[JSON_MESSAGE_ID] longValue];
        self.conversationId = [json[JSON_MESSAGE_CONVERSATION_ID] longValue];
        self.user = [[Person alloc] initFromJson:json[JSON_MESSAGE_USER]];
        self.text = json[JSON_MESSAGE_TEXT];
        self.date = [NSDate dateWithTimeIntervalSince1970:[json[JSON_MESSAGE_DATE] longValue] / 1000];
        self.state = MessageState(json[JSON_MESSAGE_STATE]);
        self.seenByUsers = [NSMutableArray new];
        
        NSArray *jsonArray = json[JSON_MESSAGE_SEEN_BY_USERS];
        for (NSDictionary *personJson in jsonArray) {
            Person *p = [[Person alloc] initFromJson:personJson];
            [self.seenByUsers addObject:p];
        }
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_MESSAGE_ID] = @(self.messageId);
    json[JSON_MESSAGE_CONVERSATION_ID] = @(self.conversationId);
    json[JSON_MESSAGE_USER] = self.user.asDictionary;
    json[JSON_MESSAGE_TEXT] = self.text;
    json[JSON_MESSAGE_DATE] = @(self.date.timeIntervalSince1970);
    json[JSON_MESSAGE_STATE] = MESSAGE_STATE_LIST[self.state];
    
    NSMutableArray *membersJson = [NSMutableArray new];
    for (Person *p in self.seenByUsers)
        [membersJson addObject:p.asDictionary];
    
    json[JSON_MESSAGE_SEEN_BY_USERS] = membersJson;
    
    return json;
}

- (NSString *)getSeenByTitle {
    NSMutableString *title = [NSMutableString new];
    
    for (Person *p in self.seenByUsers) {
        if (![p isEqual:[Settings getInstance].user] && ![p isEqual:self.user]) {
            [title appendString:p.firstname];
            [title appendString:@", "];
        }
    }
    
    if (title.length > 2)
        return [title substringToIndex:title.length - 2];
    
    return nil;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(ConversationMessage *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.messageId != aWidget.messageId)
        return NO;
    return YES;
}

@end
