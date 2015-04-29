//
//  NotificationFollowCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationFollowCell.h"

@interface NotificationFollowCell () {
    
    NotificationFollow *typedItem;
}

@end

@implementation NotificationFollowCell

+ (CGFloat)height {
    return 60;
}

- (void)awakeFromNib {
    [self setupImageViews];
}

- (void)setItem:(Notification *)item {
    super.item = item;
    
    typedItem = (NotificationFollow *)item;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"NOTIF_FOLLOW", nil), typedItem.follower.fullName];
    NSRange range = [text rangeOfString:typedItem.follower.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (typedItem.follower.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:typedItem.follower.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        self.avatarImage.image = nil;
        [self.avatarImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.avatarImage.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        weakSelf.avatarImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
}

@end
