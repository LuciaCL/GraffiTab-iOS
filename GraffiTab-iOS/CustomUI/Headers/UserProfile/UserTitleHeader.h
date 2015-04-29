//
//  UserTitleHeader.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserHeaderProtocol.h"

@interface UserTitleHeader : UIView

@property (nonatomic, assign) id <UserHeaderProtocol> delegate;
@property (nonatomic, assign) Person *item;

+ (instancetype)instantiateFromNib;

@end
