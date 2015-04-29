//
//  ConversationMessage.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ACTIVE,
    DELETED
} MessageState;

#define MESSAGE_STATE_LIST @[@"ACTIVE", @"DELETED"]

#define MessageState(str) (MessageState)[MESSAGE_STATE_LIST indexOfObject:str]

@interface ConversationMessage : NSObject <JSONSerializable>

@property (nonatomic, assign) long messageId;
@property (nonatomic, assign) long conversationId;
@property (nonatomic, strong) Person *user;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) MessageState state;
@property (nonatomic, strong) NSMutableArray *seenByUsers;

- (id)initFromJson:(NSDictionary *)json;
- (NSString *)getSeenByTitle;

@end
