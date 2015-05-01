//
//  STMediumCollectionCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullSizeCellProtocol.h"

@interface STMediumCollectionCell : UICollectionViewCell

@property (nonatomic, assign) id <FullSizeCellProtocol> delegate;
@property (nonatomic, weak) GTStreamable *item;
@property (nonatomic, weak) IBOutlet UIImageView *itemImage;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *likesLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *likeButton;
@property (nonatomic, weak) IBOutlet UIImageView *commentButton;

+ (NSString *)reusableIdentifier;

@end
