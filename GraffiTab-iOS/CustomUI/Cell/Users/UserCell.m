//
//  UserCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 02/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

+ (NSString *)reusableIdentifier {
    return @"UserCell";
}

+ (CGFloat)height {
    return 60;
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *backgroundColor = self.followButton.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.followButton.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *backgroundColor = self.followButton.backgroundColor;
    [super setSelected:selected animated:animated];
    self.followButton.backgroundColor = backgroundColor;
}

- (void)setItem:(Person *)item {
    _item = item;
    
    self.usernameLabel.text = item.mentionUsername;
    self.nameLabel.text = item.fullName;
    
    if (item.isFollowing) {
        self.followButton.layer.borderColor = UIColorFromRGB(COLOR_ORANGE).CGColor;
        self.followButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
        self.followButton.image = [[UIImage imageNamed:@"ic_action_unfollow.png"] imageWithTint:[UIColor whiteColor]];
    }
    else {
        self.followButton.layer.borderColor = UIColorFromRGB(COLOR_MAIN).CGColor;
        self.followButton.backgroundColor = [UIColor whiteColor];
        self.followButton.image = [[UIImage imageNamed:@"ic_action_follow.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)];
    }
    
    self.followButton.hidden = item.userId == [Settings getInstance].user.userId;
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:self.item.avatarId]]];
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

- (void)toggleFollow {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollow:)])
        [self.delegate didTapFollow:self];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    
    self.followButton.layer.borderColor = UIColorFromRGB(COLOR_MAIN).CGColor;
    self.followButton.layer.borderWidth = 1;
    self.followButton.layer.cornerRadius = self.followButton.frame.size.width / 2;
    [self.followButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFollow)]];
}

- (void)setupLabels {
    self.nameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
}

@end
