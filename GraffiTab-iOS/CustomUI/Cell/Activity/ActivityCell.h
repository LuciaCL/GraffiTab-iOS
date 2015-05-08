//
//  ActivityCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationCellProtocol.h"

@interface ActivityCell : UITableViewCell

@property (nonatomic, weak) id <NotificationCellProtocol> delegate;
@property (nonatomic, weak) GTActivityContainer *item;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImage;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

+ (CGFloat)height;

@end
