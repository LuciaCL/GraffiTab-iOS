//
//  HeaderViewWithImage.h
//  Example
//
//  Created by Marek Serafin on 13/10/14.
//  Copyright (c) 2014 Marek Serafin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHeaderProtocol.h"

@interface HeaderViewWithImage : UIView

@property (nonatomic, assign) id <UserHeaderProtocol> delegate;
@property (nonatomic, assign) Person *item;
@property (nonatomic, weak) IBOutlet UIImageView *coverView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backButton;
@property (nonatomic, weak) IBOutlet UIImageView *settingsButton;

+ (instancetype)instantiateFromNib;

@end
