//
//  UserCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 02/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProtocol.h"

@interface UserCell : UITableViewCell

@property (nonatomic, assign) id <UserProtocol> delegate;
@property (nonatomic, weak) Person *item;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *followButton;

+ (CGFloat)height;
+ (NSString *)reusableIdentifier;

@end
