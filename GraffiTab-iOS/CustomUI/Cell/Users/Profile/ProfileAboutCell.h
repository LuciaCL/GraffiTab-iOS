//
//  ProfileAboutCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 16/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileAboutCell : UITableViewCell

@property (nonatomic, assign) Person *item;
@property (nonatomic, assign) IBOutlet UILabel *descriptionLabel;

+ (NSString *)reusableIdentifier;

@end
