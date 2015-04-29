//
//  NotificationCommentCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationCommentCell.h"

@interface NotificationCommentCell () {
    
    NotificationComment *typedItem;
}

@end

@implementation NotificationCommentCell

+ (CGFloat)height {
    return 75;
}

- (void)awakeFromNib {
    [self setupImageViews];
}

- (void)setItem:(Notification *)item {
    super.item = item;
    
    typedItem = (NotificationComment *)item;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"NOTIF_COMMENT", nil), typedItem.commenter.fullName];
    NSRange range = [text rangeOfString:typedItem.commenter.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
    
    [self loadAvatar];
    
    if ([typedItem.item isKindOfClass:[StreamableTag class]]) // Load image only if we have a tag.
        [self loadItem];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (typedItem.commenter.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:typedItem.commenter.avatarId]]];
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
    
    StreamableTag *tag = (StreamableTag *) typedItem.item;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetGraffiti:tag.graffitiId]]];
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
    
    self.itemImage.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
}

@end
