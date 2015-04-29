//
//  NotificationCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell

@property (nonatomic, weak) Notification *item;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

+ (CGFloat)height;

@end
