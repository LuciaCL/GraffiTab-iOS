//
//  HeaderViewWithImage.m
//  Example
//
//  Created by Marek Serafin on 13/10/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import "HeaderViewWithImage.h"
#import "FXBlurView.h"

@interface HeaderViewWithImage () {
    
    UIImage *defaultBlurredImage;
}

- (IBAction)onClickAvatar:(id)sender;
- (IBAction)onClickCover:(id)sender;
- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickSettings:(id)sender;

@end

@implementation HeaderViewWithImage

+ (instancetype)instantiateFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    return [views firstObject];
}

- (IBAction)onClickAvatar:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChangeAvatar)])
        [self.delegate didTapChangeAvatar];
}

- (IBAction)onClickCover:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChangeCover)])
        [self.delegate didTapChangeCover];
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
    
    [self setupDefaultImage];
    [self setupImageViews];
    [self setupLabels];
    
    [self loadData];
}

- (void)loadData {
    self.nameLabel.text = self.item.fullName;
    self.usernameLabel.text = self.item.mentionUsername;
    
    // Configuration based on whether the user is the current user.
    NSString *imageS;
    imageS = [self canEdit] ? @"settings.png" : @"message.png";
    self.settingsButton.image = [[UIImage imageNamed:imageS] imageWithTint:[UIColor whiteColor]];
    
    [self loadAvatar];
    [self loadCover];
}

- (void)loadAvatar {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.avatarId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:self.item.avatarId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [self.avatarView setImageWithURLRequest:request placeholderImage:self.avatarView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:weakSelf.avatarView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf.avatarView.image = image;
                            } completion:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
        }];
    }
    else
        self.avatarView.image = [UIImage imageNamed:@"default_avatar.jpg"];
}

- (void)loadCover {
    __weak typeof(self) weakSelf = self;
    
    if (self.item.coverId > 0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetCover:self.item.coverId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [self.coverView setImageWithURLRequest:request placeholderImage:self.coverView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:weakSelf.coverView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf.coverView.image = image;
                            } completion:nil];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.coverView.image = defaultBlurredImage;
        }];
    }
    else {
        if (self.item.avatarId > 0) { // Darken + blur the user's avatar and use it as cover.
            // Download avatar.
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetAvatar:self.item.avatarId]]];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            
            [self.coverView setImageWithURLRequest:request placeholderImage:self.coverView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [weakSelf setDarkBlurredImageAsCover:image];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                weakSelf.coverView.image = defaultBlurredImage;
            }];
        }
        else
            weakSelf.coverView.image = defaultBlurredImage;
    }
}

- (void)setDarkBlurredImageAsCover:(UIImage *)i {
    UIImage *darken = [i colorizeImagWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
    UIImage *blur = [darken blurredImageWithRadius:40 iterations:2 tintColor:nil];
    
    [UIView transitionWithView:self.coverView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.coverView.image = blur;
                    } completion:nil];
}

- (BOOL)canEdit {
    return [self.item isEqual:[Settings getInstance].user];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.borderWidth = 2;
    self.avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.coverView.image = defaultBlurredImage;
    
    self.backButton.image = [self.backButton.image imageWithTint:[UIColor whiteColor]];
    self.settingsButton.image = [self.settingsButton.image imageWithTint:[UIColor whiteColor]];
}

- (void)setupLabels {
    NSArray *items = @[self.nameLabel, self.usernameLabel];
    for (UIView *v in items) {
        v.layer.shadowOpacity = 1.0;
        v.layer.shadowRadius = 0.0;
        v.layer.shadowColor = [UIColor blackColor].CGColor;
        v.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    }
}

- (void)setupDefaultImage {
    UIImage *i = [UIImage imageNamed:@"header_upsidedown.png"];
    UIImage *darken = [i colorizeImagWithColor:[UIColor colorWithWhite:0 alpha:0.5]];
    UIImage *blur = [darken blurredImageWithRadius:40 iterations:2 tintColor:nil];

    defaultBlurredImage = blur;
}

@end
