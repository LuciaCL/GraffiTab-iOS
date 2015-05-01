//
//  STVideoThumbnailCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "STVideoThumbnailCollectionCell.h"

@interface STVideoThumbnailCollectionCell () {
    
    GTStreamableVideo *typedItem;
}

@end

@implementation STVideoThumbnailCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoThumbnailCollectionCell";
}

- (void)setItem:(GTStreamable *)item {
    super.item = item;
    
    typedItem = (GTStreamableVideo *)item;
}

@end
