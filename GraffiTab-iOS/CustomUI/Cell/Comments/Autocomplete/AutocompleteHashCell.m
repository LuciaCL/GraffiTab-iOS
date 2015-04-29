//
//  AutocompleteHashCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AutocompleteHashCell.h"

@implementation AutocompleteHashCell

+ (CGFloat)height {
    return 53;
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)setItem:(NSString *)item {
    _item = item;
    
    self.hashLabel.text = item;
}

@end
