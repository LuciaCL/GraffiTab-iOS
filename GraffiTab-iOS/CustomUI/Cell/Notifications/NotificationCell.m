//
//  NotificationCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

+ (CGFloat)height {
    return 44;
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)setItem:(Notification *)item {
    _item = item;
    
    self.dateLabel.text = [DateUtils timePassedSinceDate:item.date];
}

@end
