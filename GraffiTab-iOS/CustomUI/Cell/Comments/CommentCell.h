//
//  CommentCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 28/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAttributedHighlightLabel.h"
#import "TweetProtocol.h"

@interface CommentCell : UITableViewCell <AMAttributedHighlightLabelDelegate>

@property (nonatomic, weak) GTComment *item;
@property (nonatomic, assign) id<TweetProtocol> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet AMAttributedHighlightLabel *messageTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end
