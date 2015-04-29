//
//  MessagesViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "TweetProtocol.h"
#import "EditCellProtocol.h"

@interface MessagesViewController : BackButtonSLKTextViewController <TweetProtocol, EditCellProtocol>

@property (nonatomic, assign) Conversation *conversation;

- (void)processMessageNotification:(NSDictionary *)userInfo;
- (void)processShowTypingIndicatorNotification:(NSDictionary *)userInfo;
- (void)processHideTypingIndicatorNotification:(NSDictionary *)userInfo;

@end
