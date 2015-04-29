//
//  MessageCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAttributedHighlightLabel.h"
#import "TweetProtocol.h"
#import "EditCellProtocol.h"

@interface MessageCell : UITableViewCell <AMAttributedHighlightLabelDelegate>

@property (nonatomic, weak) Conversation *conversation;
@property (nonatomic, weak) ConversationMessage *item;
@property (nonatomic, assign) id<TweetProtocol, EditCellProtocol> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *balloonView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet AMAttributedHighlightLabel *messageTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *seenByLabel;

@end
