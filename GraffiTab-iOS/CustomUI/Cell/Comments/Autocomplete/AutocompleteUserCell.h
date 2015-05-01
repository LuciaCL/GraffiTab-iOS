//
//  AutocompleteUserCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutocompleteUserCell : UITableViewCell

@property (nonatomic, weak) GTPerson *item;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;

+ (CGFloat)height;

@end
