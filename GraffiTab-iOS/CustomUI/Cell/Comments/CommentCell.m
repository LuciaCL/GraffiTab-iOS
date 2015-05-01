//
//  CommentCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 28/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (void)awakeFromNib {
    [self setupImageViews];
    [self setupLabels];
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)onClickAvatar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatar:)])
        [self.delegate didClickAvatar:self.item.user];
}

- (void)setItem:(GTComment *)item {
    _item = item;
    
    // Setup username label.
    NSString *title = [NSString stringWithFormat:@"%@ %@", item.user.fullName, item.user.mentionUsername];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:[title rangeOfString:item.user.mentionUsername]];
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:[title rangeOfString:item.user.mentionUsername]];
    
    self.usernameLabel.attributedText = attString;
    
    // Setup comment label.
    self.messageTextLabel.mentionTextColor = UIColorFromRGB(COLOR_AWESOME);
    self.messageTextLabel.hashtagTextColor = UIColorFromRGB(COLOR_AWESOME);
    [self.messageTextLabel setString:item.text];
    CGSize s = [self.messageTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - self.messageTextLabel.frame.origin.x - 10, MAXFLOAT)];
    self.messageTextLabel.frame = CGRectMake(self.messageTextLabel.frame.origin.x, self.messageTextLabel.frame.origin.y, s.width, s.height);
    self.dateLabel.text = [DateUtils timePassedSinceDate:item.date];
    
    [self setupHyperlinkLabel];
    
    [self loadAvatar];
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

- (void)setupImageViews {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAvatar)]];
}

- (void)setupLabels {
    self.usernameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
}

- (void)setupHyperlinkLabel {
    self.messageTextLabel.delegate = self;
}

@end
