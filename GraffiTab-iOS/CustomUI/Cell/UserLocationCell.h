//
//  UserLocationCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLocationCell : UITableViewCell

@property (nonatomic, weak) UserLocation *item;
@property (nonatomic, weak) IBOutlet UIImageView *locationImage;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@end
