//
//  MessageCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    [self setupHyperlinkLabel];
    [self setupAvatarView];
}

- (void)onClickAvatar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatar:)])
        [self.delegate didClickAvatar:self.item.user];
}

- (void)delete:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDelete:)])
        [self.delegate onDelete:self.item];
}

- (void)edit:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEdit:)])
        [self.delegate onEdit:self.item];
}

- (void)setItem:(GTConversationMessage *)item {
    _item = item;
    
    // Setup comment label.
    UIColor *dateColor = [UIColor lightGrayColor];
    self.messageTextLabel.backgroundColor = [UIColor clearColor];
    self.messageTextLabel.mentionTextColor = UIColorFromRGB(COLOR_LINKS);
    self.messageTextLabel.hashtagTextColor = UIColorFromRGB(COLOR_LINKS);
    
    if ([self.item.user isEqual:[GTLifecycleManager user]]) // Mine.
        self.messageTextLabel.textColor = UIColorFromRGB(COLOR_MAIN);
    else // Theirs.
        self.messageTextLabel.textColor = [UIColor whiteColor];
    
    NSMutableAttributedString *attString;
    if (item.state == DELETED) {
        NSString *text = @"This message has been removed.";
        [self.messageTextLabel setString:text];
        
        attString = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageTextLabel.attributedText];
        [attString addAttribute:NSForegroundColorAttributeName value:dateColor range:[text rangeOfString:text]];
        [attString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:self.messageTextLabel.font.pointSize] range:[text rangeOfString:text]];
    }
    else {
        NSString *dateString = [NSString stringWithFormat:@"   %@", [DateUtils timePassedSinceDate:item.date]];
        NSString *text = [NSString stringWithFormat:@"%@%@", item.text, dateString];
        [self.messageTextLabel setString:text];
        
        // Setup time label.
        attString = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageTextLabel.attributedText];
        [attString addAttribute:NSForegroundColorAttributeName value:dateColor range:[text rangeOfString:dateString]];
        [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:[text rangeOfString:dateString]];
        [attString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-0.4] range:[text rangeOfString:dateString]];
    }
    
    self.messageTextLabel.attributedText = attString;
    
    // Setup author label.
    self.authorLabel.text = item.user.firstname;
    
    // Setup seen label.
    if (item.seenByUsers.count == self.conversation.members.count)
        self.seenByLabel.text = self.conversation.members.count == 2 ? @"Seen" : @"Seen by Everyone";
    else {
        if (self.conversation.members.count == 2)
            self.seenByLabel.hidden = YES;
        else {
            NSString *seenTitle = item.getSeenByTitle;
            if (seenTitle)
                self.seenByLabel.text = [NSString stringWithFormat:@"Seen by %@", seenTitle];
            else
                self.seenByLabel.hidden = YES;
        }
    }
    
    [self layoutComponents];
    
    [self loadAvatar];
}

- (void)layoutComponents {
    // Setup balloon view.
    if ([self.item.user isEqual:[GTLifecycleManager user]]) // Mine.
        [self layoutMyView];
    else // Theirs.
        [self layoutTheirView];
    
    CGRect f = self.balloonView.frame;
    f.size.height += 3;
    self.balloonView.frame = f;
    
    // Setup author label.
    f = self.authorLabel.frame;
    f.origin.x = self.messageTextLabel.frame.origin.x;
    f.size.width = self.messageTextLabel.frame.size.width;
    self.authorLabel.frame = f;
}

- (void)layoutMyView {
    CGSize size = [self.messageTextLabel sizeThatFits:CGSizeMake(240, 480)];
    int originY = self.authorLabel.hidden ? 2 : self.authorLabel.frame.origin.y + self.authorLabel.frame.size.height - 2;
    
    // Layout balloon view.
    self.balloonView.frame = CGRectMake(self.frame.size.width - (size.width + 28), originY, size.width + 25, size.height + 15);
    self.balloonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.balloonView.image = [[UIImage imageNamed:@"bubble_mine"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    
    self.messageTextLabel.frame = CGRectMake(307 - (size.width + 5), self.balloonView.frame.origin.y + 6, size.width + 5, size.height);
    self.messageTextLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    // Layout avatar.
    CGRect f = self.messageTextLabel.frame;
    f.origin.x -= self.avatarView.frame.size.width + 7;
    self.messageTextLabel.frame = f;
    
    f = self.balloonView.frame;
    f.origin.x -= self.avatarView.frame.size.width + 7;
    self.balloonView.frame = f;
    
    f = self.avatarView.frame;
    f.origin.x = self.balloonView.frame.origin.x + self.balloonView.frame.size.width + 3;
    f.origin.y = self.balloonView.frame.origin.y + self.balloonView.frame.size.height - f.size.height + 10;
    self.avatarView.frame = f;
    
    // Layout seen by label.
    f = self.seenByLabel.frame;
    f.origin.x = 10;
    f.origin.y = self.balloonView.frame.origin.y + self.balloonView.frame.size.height - 3;
    f.size.width = self.balloonView.frame.origin.x + self.balloonView.frame.size.width - 15;
    self.seenByLabel.frame = f;
    self.seenByLabel.textAlignment = NSTextAlignmentRight;
}

- (void)layoutTheirView {
    CGSize size = [self.messageTextLabel sizeThatFits:CGSizeMake(240, 480)];
    int originY = self.authorLabel.hidden ? 2 : self.authorLabel.frame.origin.y + self.authorLabel.frame.size.height - 2;
    
    // Layout balloon view.
    self.balloonView.frame = CGRectMake(0, originY, size.width + 28, size.height + 15);
    self.balloonView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.balloonView.image = [[UIImage imageNamed:@"bubble_theirs"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
    
    self.messageTextLabel.frame = CGRectMake(16, self.balloonView.frame.origin.y + 6, size.width + 5, size.height);
    self.messageTextLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    // Layout avatar.
    CGRect f = self.avatarView.frame;
    f.origin.x = 7;
    f.origin.y = self.balloonView.frame.origin.y + self.balloonView.frame.size.height - f.size.height + 10;
    self.avatarView.frame = f;
    
    int origin = self.avatarView.frame.size.width + 10;
    f = self.messageTextLabel.frame;
    f.origin.x += origin;
    self.messageTextLabel.frame = f;
    
    f = self.balloonView.frame;
    f.origin.x += origin;
    self.balloonView.frame = f;
    
    // Layout seen by label.
    f = self.seenByLabel.frame;
    f.origin.x = self.balloonView.frame.origin.x + 10;
    f.origin.y = self.balloonView.frame.origin.y + self.balloonView.frame.size.height - 3;
    f.size.width = self.frame.size.width - f.origin.x;
    self.seenByLabel.frame = f;
    self.seenByLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.user.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:self.item.user.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        self.avatarView.image = nil;
        [self.avatarView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.avatarView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        self.avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

#pragma mark - AMAttributedHighlightLabelDelegate

- (void)selectedHashtag:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickHashtag:)])
        [self.delegate didClickHashtag:[string substringFromIndex:1]];
}

- (void)selectedLink:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickLink:)])
        [self.delegate didClickLink:string];
}

- (void)selectedMention:(NSString *)string {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUsername:)])
        [self.delegate didClickUsername:[string substringFromIndex:1]];
}

#pragma mark - Setup

- (void)setupHyperlinkLabel {
    self.messageTextLabel.delegate = self;
}

- (void)setupAvatarView {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAvatar)]];
}

@end
