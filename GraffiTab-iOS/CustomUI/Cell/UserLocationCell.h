//
//  UserLocationCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface UserLocationCell : MGSwipeTableCell

@property (nonatomic, weak) GTUserLocation *item;
@property (nonatomic, weak) IBOutlet UIImageView *locationImage;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *trackingImage;

@end
