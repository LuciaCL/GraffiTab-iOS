//
//  ActivityCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ActivityCell.h"

@implementation ActivityCell

+ (CGFloat)height {
    return 44;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 7;
    frame.origin.y += 7;
    frame.size.width -= 2 * 7;
    frame.size.height -= 7;
    
    [super setFrame:frame];
}

- (void)awakeFromNib {
    [self setupAvatar];
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)onClickAvatar {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapAvatar:)])
        [self.delegate didTapAvatar:self.item.activityUser];
}

- (void)setItem:(GTActivityContainer *)item {
    _item = item;
    
    self.dateLabel.text = [DateUtils timePassedSinceDate:item.date];
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.activityUser.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:self.item.activityUser.avatarId]]];
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

#pragma mark - Setup

- (void)setupAvatar {
    self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2;
    [self.avatarImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAvatar)]];
    
    self.layer.cornerRadius = 5;
}

@end
