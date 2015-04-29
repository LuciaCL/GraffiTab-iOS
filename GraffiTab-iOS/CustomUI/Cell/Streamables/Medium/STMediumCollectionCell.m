//
//  STMediumCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STMediumCollectionCell.h"

@implementation STMediumCollectionCell

+ (NSString *)reusableIdentifier {
    return nil;
}

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 3;

    [self setupButtons];
    [self setupImageViews];
}

- (void)onClickButtonLike {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLike:)])
        [self.delegate didTapLike:self.item];
}

- (void)onClickButtonComment {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapComment:)])
        [self.delegate didTapComment:self.item];
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

- (void)setItem:(Streamable *)item {
    _item = item;
    
    // Setup labels.
    self.nameLabel.text = item.user.fullName;
    self.usernameLabel.text = item.user.mentionUsername;
    self.likesLabel.text = [NSString stringWithFormat:@"%i", item.likesCount];
    self.commentsLabel.text = [NSString stringWithFormat:@"%i", item.commentsCount];
    
    if (item.isLiked)
        self.likeButton.image = [[UIImage imageNamed:@"unlike.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)];
    else
        self.likeButton.image = [[UIImage imageNamed:@"like.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)];
    
    [self setupLabels];
    
    [self loadAvatar];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.user.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:self.item.user.avatarId]]];
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
    
    CGRect f = self.likesLabel.frame;
    f.origin.y = self.likeButton.frame.origin.y;
    f.size.height = self.likeButton.frame.size.height;
    self.likesLabel.frame = f;
    
    f = self.commentsLabel.frame;
    f.origin.y = self.commentButton.frame.origin.y;
    f.size.height = self.commentButton.frame.size.height;
    self.commentsLabel.frame = f;
    
    f = self.commentButton.frame;
    f.origin.x = self.likesLabel.frame.origin.x + self.likesLabel.frame.size.width + 10;
    self.commentButton.frame = f;
    
    f = self.commentsLabel.frame;
    f.origin.x = self.commentButton.frame.origin.x + self.commentButton.frame.size.width + 4;
    self.commentsLabel.frame = f;
    
    self.nameLabel.textColor = UIColorFromRGB(COLOR_USERNAME);
    self.likesLabel.textColor = UIColorFromRGB(COLOR_MAIN);
    self.commentsLabel.textColor = UIColorFromRGB(COLOR_MAIN);
}

- (void)setupButtons {
    self.commentButton.image = [self.commentButton.image imageWithTint:UIColorFromRGB(COLOR_MAIN)];
    
    self.likeButton.userInteractionEnabled = YES;
    [self.likeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickButtonLike)]];
    self.commentButton.userInteractionEnabled = YES;
    [self.commentButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickLabelComment)]];
    
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
}

@end
