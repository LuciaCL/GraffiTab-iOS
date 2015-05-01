//
//  ConversationCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import "GLGroupChatPicView.h"

@interface ConversationCell : MGSwipeTableCell

@property (nonatomic, weak) GTConversation *item;
@property (nonatomic, weak) IBOutlet GLGroupChatPicView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *unseenMessagesLabel;

@end
