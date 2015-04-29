//
//  UserTitleHeader.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "UserTitleHeader.h"

@interface UserTitleHeader () {
    
    IBOutlet UIImageView *backButton;
    IBOutlet UIImageView *settingsButton;
    IBOutlet UILabel *usernameLabel;
}

- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickSettings:(id)sender;

@end

@implementation UserTitleHeader

+ (instancetype)instantiateFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    return [views firstObject];
}

- (IBAction)onClickBack:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapBack)])
        [self.delegate didTapBack];
}

- (IBAction)onClickSettings:(id)sender {
    if ([self canEdit]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapSettings)])
            [self.delegate didTapSettings];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapMessage)])
            [self.delegate didTapMessage];
    }
}

- (void)setItem:(Person *)item {
    _item = item;
    
    [self setupImageViews];
    
    [self loadData];
}

- (void)loadData {
    usernameLabel.text = self.item.fullName;
    
    // Configuration based on whether the user is the current user.
    NSString *imageS;
    imageS = [self canEdit] ? @"settings.png" : @"message.png";
    settingsButton.image = [[UIImage imageNamed:imageS] imageWithTint:[UIColor whiteColor]];
}

- (BOOL)canEdit {
    return [self.item isEqual:[Settings getInstance].user];
}

#pragma mark - Setup

- (void)setupImageViews {
    backButton.image = [backButton.image imageWithTint:[UIColor whiteColor]];
    settingsButton.image = [settingsButton.image imageWithTint:[UIColor whiteColor]];
}

@end
