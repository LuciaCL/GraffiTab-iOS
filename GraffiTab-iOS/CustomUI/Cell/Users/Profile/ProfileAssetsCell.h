//
//  ProfileAssetsCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 16/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHeaderProtocol.h"

@interface ProfileAssetsCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) id <UserHeaderProtocol> delegate;
@property (nonatomic, assign) GTPerson *item;

+ (CGFloat)height;
+ (NSString *)reusableIdentifier;

@end
