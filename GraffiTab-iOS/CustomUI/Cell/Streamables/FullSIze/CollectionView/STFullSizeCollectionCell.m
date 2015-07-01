//
//  STFullSizeCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STFullSizeCollectionCell.h"

@implementation STFullSizeCollectionCell

+ (NSString *)reusableIdentifier {
    return nil;
}

+ (CGFloat)height {
    return 44;
}

- (void)awakeFromNib {
    [self setupImageViews];
    [self setupButtons];
}

- (void)onClickButtonLike {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLike:)])
        [self.delegate didTapLike:self.item];
}

- (void)onClickButtonComment {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapComment:)])
        [self.delegate didTapComment:self.item];
}

- (void)onClickButtonShare {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapShare:image:)])
        [self.delegate didTapShare:self.item image:self.itemImage.image];
}

- (void)onClickLabelLike {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLikesLabel:)])
        [self.delegate didTapLikesLabel:self.item];
}

- (void)onClickLabelComment {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapComment:)])
        [self.delegate didTapComment:self.item];
}

- (void)onClickUser {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOwner:)])
        [self.delegate didTapOwner:self.item];
}

- (void)setItem:(GTStreamable *)item {
    _item = item;
    
    // Setup labels.
    self.dateLabel.text = [DateUtils timePassedSinceDate:item.date];
    
    self.nameLabel.text = item.user.fullName;
    self.usernameLabel.text = item.user.mentionUsername;
    self.likesLabel.text = [NSString stringWithFormat:@"%i %@", item.likesCount, item.likesCount == 1 ? @"Like" : @"Likes"];
    self.commentsLabel.text = [NSString stringWithFormat:@"%i %@", item.commentsCount, item.commentsCount == 1 ? @"Comment" : @"Comments"];
    
    // Setup Like button
    [self.likeButton setImage:[[UIImage imageNamed:item.isLiked ? @"unlike.png" : @"like.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    
    [self setupLabels];
    
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

#pragma mark - Setup

- (void)setupLabels {
    [self.likesLabel sizeToFit];
    [self.commentsLabel sizeToFit];
    
    CGRect f = self.commentsLabel.frame;
    f.origin.x = self.likesLabel.frame.origin.x + self.likesLabel.frame.size.width + 10;
    f.origin.y = self.likesLabel.frame.origin.y;
    f.size.height = self.likesLabel.frame.size.height;
    self.commentsLabel.frame = f;
    
    self.nameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
}

- (void)setupButtons {
    [self.likeButton setImage:[self.likeButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    [self.commentButton setImage:[self.commentButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    [self.shareButton setImage:[self.shareButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    
    [self.likeButton addTarget:self action:@selector(onClickButtonLike) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton addTarget:self action:@selector(onClickButtonComment) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(onClickButtonShare) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentsLabel.userInteractionEnabled = YES;
    [self.commentsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLabelComment)]];
    
    self.likesLabel.userInteractionEnabled = YES;
    [self.likesLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLabelLike)]];
    
    self.avatarView.userInteractionEnabled = YES;
    [self.avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUser)]];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUser)]];
    self.usernameLabel.userInteractionEnabled = YES;
    [self.usernameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickUser)]];
}

- (void)setupImageViews {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    
    self.itemImage.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
    [Utils applyShadowEffectToView:self.containerView];
}

@end
