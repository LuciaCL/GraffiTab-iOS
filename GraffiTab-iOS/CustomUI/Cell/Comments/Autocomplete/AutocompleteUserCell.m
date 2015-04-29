//
//  AutocompleteUserCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AutocompleteUserCell.h"

@implementation AutocompleteUserCell

+ (CGFloat)height {
    return 53;
}

- (void)awakeFromNib {
    [self setupImageViews];
    [self setupLabels];
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)setItem:(Person *)item {
    _item = item;
    
    self.nameLabel.text = item.fullName;
    self.usernameLabel.text = item.mentionUsername;
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatarForUsername:self.item.username]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.avatarView.image = nil;
    [self.avatarView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"default_avatar.jpg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.avatarView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
    }];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
}

- (void)setupLabels {
    self.nameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
}

@end
