//
//  NotificationWelcomeCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationWelcomeCell.h"

@implementation NotificationWelcomeCell

+ (CGFloat)height {
    return 60;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setItem:(Notification *)item {
    super.item = item;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"NOTIF_WELCOME", nil), item.user.firstname];
    NSRange range = [text rangeOfString:item.user.firstname];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
}

@end
