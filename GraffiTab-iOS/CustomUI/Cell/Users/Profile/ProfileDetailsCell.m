//
//  ProfileDetailsCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 16/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ProfileDetailsCell.h"

@interface ProfileDetailsCell () {
    
    IBOutlet UILabel *graffitiLabel;
    IBOutlet UILabel *followersLabel;
    IBOutlet UILabel *followingLabel;
    IBOutlet UILabel *graffitiCountLabel;
    IBOutlet UILabel *followersCountLabel;
    IBOutlet UILabel *followingCountLabel;
    IBOutlet UILabel *buttonTitle;
    IBOutlet UIImageView *buttonImage;
    IBOutlet UIView *followButton;
    IBOutlet UIView *graffitiButton;
    IBOutlet UIView *followersButton;
    IBOutlet UIView *followingButton;
}

@end

@implementation ProfileDetailsCell

+ (NSString *)reusableIdentifier {
    return @"ProfileDetailsCell";
}

+ (CGFloat)height {
    return 60;
}

- (void)awakeFromNib {
    // Initialization code
    
    [self setupButtons];
}

- (void)onClickFollow {
    if ([self canEdit]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSettings)])
            [self.delegate didTapSettings];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollow)])
            [self.delegate didTapFollow];
    }
}

- (void)onClickGraffiti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapGraffiti)])
        [self.delegate didTapGraffiti];
}

- (void)onClickFollowers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowers)])
        [self.delegate didTapFollowers];
}

- (void)onClickFollowing {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowing)])
        [self.delegate didTapFollowing];
}

- (void)setItem:(GTPerson *)item {
    _item = item;
    
    graffitiCountLabel.text = self.item.streamablesCountAsString;
    followersCountLabel.text = self.item.followersCountAsString;
    followersLabel.text = self.item.followersCount == 1 ? @"Follower" : @"Followers";
    followingCountLabel.text = self.item.followingCountAsString;
    
    if ([self canEdit]) {
        buttonImage.image = [UIImage imageNamed:@"edit.png"];
        buttonTitle.text = @"Edit Profile";
    }
    else {
        if (self.item.isFollowing) {
            buttonImage.image = [[UIImage imageNamed:@"ic_action_unfollow.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)];
            buttonTitle.text = @"Following";
            buttonTitle.textColor = UIColorFromRGB(COLOR_MAIN);
        }
        else {
            buttonImage.image = [[UIImage imageNamed:@"ic_action_follow.png"] imageWithTint:[UIColor blackColor]];
            buttonTitle.text = @"Follow";
            buttonTitle.textColor = [UIColor blackColor];
        }
    }
}

- (BOOL)canEdit {
    return [self.item isEqual:[GTLifecycleManager user]];
}

#pragma mark - Setup

- (void)setupButtons {
    [followButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFollow)]];
    [graffitiButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickGraffiti)]];
    [followersButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFollowers)]];
    [followingButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFollowing)]];
}

@end
