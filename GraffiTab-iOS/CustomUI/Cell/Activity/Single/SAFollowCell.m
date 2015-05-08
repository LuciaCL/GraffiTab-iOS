//
//  SAFollowCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SAFollowCell.h"

@interface SAFollowCell () {
    
    GTActivityFollow *typedItem;
}

@end

@implementation SAFollowCell

+ (CGFloat)height {
    return 80;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupImageViews];
}

- (void)setItem:(GTActivityContainer *)item {
    super.item = item;
    
    typedItem = (GTActivityFollow *)item.activities.firstObject;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"SA_FOLLOW", nil), item.activityUser.fullName, typedItem.followedUser.fullName];
    NSRange range = [text rangeOfString:item.activityUser.fullName];
    NSRange range2 = [text rangeOfString:typedItem.followedUser.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range2];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range2];
    
    self.infoLabel.attributedText = string;
    
    [self loadItem];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    if (typedItem.followedUser.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:typedItem.followedUser.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        self.itemImage.image = nil;
        [self.itemImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.itemImage.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.itemImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        self.itemImage.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.itemImage.layer.cornerRadius = self.itemImage.frame.size.width / 2;
}

@end
