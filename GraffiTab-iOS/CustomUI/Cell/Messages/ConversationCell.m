//
//  ConversationCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "ConversationCell.h"

@implementation ConversationCell

- (void)awakeFromNib {
    [self setupLabels];
    [self setupAvatarLabel];
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)setItem:(GTConversation *)item {
    _item = item;
    
    NSMutableArray *otherMembers = [item findOtherMembers];
    
    if (otherMembers.count == 1) { // Chat with a single user.
        // Setup username label.
        if (item.name)
            self.usernameLabel.text = item.name;
        else {
            GTPerson *u = [otherMembers lastObject];

            NSString *title = [NSString stringWithFormat:@"%@ %@", u.fullName, u.mentionUsername];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
            [attString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[title rangeOfString:u.mentionUsername]];
            [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:[title rangeOfString:u.mentionUsername]];
            
            self.usernameLabel.attributedText = attString;
        }
    }
    else { // Chat with a group of users.
        if (item.name)
            self.usernameLabel.text = item.name;
        else
            self.usernameLabel.text = item.getGroupChatTitle;
    }
    
    // Setup message label.
    if (item.lastMessage.state == DELETED) {
        NSString *text = @"This message has been removed.";
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
        [attString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:13] range:[text rangeOfString:text]];
        self.messageTextLabel.attributedText = attString;
    }
    else
        self.messageTextLabel.text = item.lastMessage.text;
    
    // Setup date label.
    self.dateLabel.text = [DateUtils timePassedSinceDate:item.lastMessage.date];
    
    // Setup new messages count.
    self.unseenMessagesLabel.text = [NSString stringWithFormat:@"%i", item.unseenMessagesCount];
    [self buildBadge:self.unseenMessagesLabel];
    
    if (item.imageId <= 0)
        [self loadAvatars:otherMembers];
    else
        [self loadConversationImage];
}

- (void)loadConversationImage {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetConversationImage:self.item.imageId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLResponse *response;
        NSError *error;
        NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        UIImage *i = [UIImage imageWithData:imageData];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.avatarView reset];
            self.avatarView.totalEntries = 1;
            
            [self.avatarView addImage:i withInitials:nil];
            
            [self.avatarView updateLayout];
        });
    });
}

- (void)loadAvatars:(NSMutableArray *)otherMembers {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *images = [NSMutableArray new];
        
        for (GTPerson *p in otherMembers) {
            UIImage *i;
            if (p.avatarId > 0) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:p.avatarId]]];
                request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
                
                NSURLResponse *response;
                NSError *error;
                NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                i = [UIImage imageWithData:imageData];
            }
            
            [images addObject:i ? i : @""];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.avatarView reset];
            self.avatarView.totalEntries = otherMembers.count;
            
            for (int i = 0; i < images.count; i++)
                [self.avatarView addImage:[images[i] isKindOfClass:[UIImage class]] ? images[i] : nil withInitials:[otherMembers[i] fullName]];
            
            [self.avatarView updateLayout];
        });
    });
}

- (void)buildBadge:(UILabel *)badge {
    if ([badge.text isEqualToString:@"0"] || badge.text.length <= 0)
        badge.hidden = YES;
    else
        badge.hidden = NO;
    
    badge.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    badge.textColor = [UIColor whiteColor];
    
    [badge sizeToFit];
    
    CGRect f = badge.frame;
    f.size.height = 20;
    f.size.width += 12;
    f.origin.x = self.frame.size.width - f.size.width - 6;
    badge.frame = f;
    
    badge.layer.cornerRadius = badge.frame.size.height / 2;
    [badge.layer setMasksToBounds:YES];
}

#pragma mark - Setup

- (void)setupLabels {
    self.usernameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
}

- (void)setupAvatarLabel {
    self.avatarView.backgroundColor = [UIColor clearColor];
}

@end
