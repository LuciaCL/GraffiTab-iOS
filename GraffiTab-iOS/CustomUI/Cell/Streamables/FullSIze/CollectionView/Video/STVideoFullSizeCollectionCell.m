//
//  STVideoFullSizeCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STVideoFullSizeCollectionCell.h"

@interface STVideoFullSizeCollectionCell () {
    
    GTStreamableVideo *typedItem;
}

@end

@implementation STVideoFullSizeCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoFullSizeCollectionCell";
}

+ (CGFloat)height {
    return 464;
}

- (void)setItem:(GTStreamable *)item {
    super.item = item;
    
    typedItem = (GTStreamableVideo *)item;
}

@end
