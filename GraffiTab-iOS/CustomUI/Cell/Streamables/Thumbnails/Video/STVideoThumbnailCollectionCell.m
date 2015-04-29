//
//  STVideoThumbnailCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "STVideoThumbnailCollectionCell.h"

@interface STVideoThumbnailCollectionCell () {
    
    StreamableVideo *typedItem;
}

@end

@implementation STVideoThumbnailCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoThumbnailCollectionCell";
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableVideo *)item;
}

@end
