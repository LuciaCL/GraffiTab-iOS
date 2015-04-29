//
//  STVideoFullSizeTableCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STVideoFullSizeTableCell.h"

@interface STVideoFullSizeTableCell () {
    
    StreamableVideo *typedItem;
}

@end

@implementation STVideoFullSizeTableCell

+ (NSString *)reusableIdentifier {
    return @"STVideoFullSizeTableCell";
}

+ (CGFloat)height {
    return 464;
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableVideo *)item;
}

@end
