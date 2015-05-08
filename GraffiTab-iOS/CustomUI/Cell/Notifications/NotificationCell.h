//
//  NotificationCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationCellProtocol.h"

@interface NotificationCell : UITableViewCell

@property (nonatomic, weak) id <NotificationCellProtocol> delegate;
@property (nonatomic, weak) GTNotification *item;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

+ (CGFloat)height;

@end
