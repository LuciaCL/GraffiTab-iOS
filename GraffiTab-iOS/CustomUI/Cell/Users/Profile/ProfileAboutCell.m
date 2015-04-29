//
//  ProfileAboutCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 16/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ProfileAboutCell.h"

@implementation ProfileAboutCell

+ (NSString *)reusableIdentifier {
    return @"ProfileAboutCell";
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setItem:(Person *)item {
    _item = item;
    
    CGRect f = self.descriptionLabel.frame;
    f.size.width = 304;
    self.descriptionLabel.frame = f;
    
    NSString *txt = item.aboutString;
    
    if (item.website) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:txt];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:129.0/255.0 green:171.0/255.0 blue:193.0/255.0 alpha:1.0] range:[txt rangeOfString:item.website]];
        self.descriptionLabel.attributedText = attString;
    }
    else
        self.descriptionLabel.text = txt;
    
    [self.descriptionLabel sizeToFit];
    
    CGPoint c = self.descriptionLabel.center;
    c.x = self.frame.size.width / 2;
    self.descriptionLabel.center = c;
}

@end
