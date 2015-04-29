//
//  STThumbnailCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "STThumbnailCollectionCell.h"

@implementation STThumbnailCollectionCell

+ (NSString *)reusableIdentifier {
    return nil;
}

- (void)awakeFromNib {
    [self setupImageViews];
}

- (void)setItem:(Streamable *)item {
    _item = item;
}

#pragma mark - Setup

- (void)setupImageViews {
    self.itemImage.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
}

@end
