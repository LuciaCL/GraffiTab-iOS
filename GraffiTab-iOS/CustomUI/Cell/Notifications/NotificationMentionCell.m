//
//  NotificationMentionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationMentionCell.h"

@interface NotificationMentionCell () {
    
    GTNotificationMention *typedItem;
}

@end

@implementation NotificationMentionCell

+ (CGFloat)height {
    return 75;
}

- (void)awakeFromNib {
    [self setupImageViews];
}

- (void)onClickAvatar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatar:)])
        [self.delegate didTapAvatar:typedItem.mentioner];
}

- (void)setItem:(GTNotification *)item {
    super.item = item;
    
    typedItem = (GTNotificationMention *)item;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"NOTIF_MENTION", nil), typedItem.mentioner.fullName];
    NSRange range = [text rangeOfString:typedItem.mentioner.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
    
    [self loadAvatar];
    
    if ([typedItem.item isKindOfClass:[GTStreamableTag class]]) // Load image only if we have a tag.
        [self loadItem];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (typedItem.mentioner.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:typedItem.mentioner.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        self.avatarImage.image = nil;
        [self.avatarImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.avatarImage.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        self.avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    GTStreamableTag *tag = (GTStreamableTag *) typedItem.item;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetGraffiti:tag.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.itemImage.image = nil;
    [self.itemImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.itemImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.itemImage.image = nil;
    }];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
    [self.avatarImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAvatar)]];
    
    self.itemImage.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
}

@end
