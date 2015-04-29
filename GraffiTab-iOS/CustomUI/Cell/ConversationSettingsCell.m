//
//  ConversationSettingsCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 13/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ConversationSettingsCell.h"

@implementation ConversationSettingsCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect f = self.imageView.frame;
    f.size.width = 35;
    f.size.height = 35;
    self.imageView.frame = f;
    
    CGPoint c = self.imageView.center;
    c.y = self.frame.size.height / 2;
    self.imageView.center = c;
    
    f = self.textLabel.frame;
    f.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + 15;
    self.textLabel.frame = f;
    
    f = self.detailTextLabel.frame;
    f.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + 15;
    self.detailTextLabel.frame = f;
    
    [self setupImageView];
}

#pragma mark - Setup

- (void)setupImageView {
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
}

@end
