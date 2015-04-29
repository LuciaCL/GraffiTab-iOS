//
//  STVideoFullSizeCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STVideoFullSizeCollectionCell.h"

@interface STVideoFullSizeCollectionCell () {
    
    StreamableVideo *typedItem;
}

@end

@implementation STVideoFullSizeCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoFullSizeCollectionCell";
}

+ (CGFloat)height {
    return 464;
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableVideo *)item;
}

@end
