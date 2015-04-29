//
//  STVideoMediumCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STVideoMediumCollectionCell.h"

@interface STVideoMediumCollectionCell () {
    
    StreamableVideo *typedItem;
}

@end

@implementation STVideoMediumCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoMediumCollectionCell";
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableVideo *)item;
}

@end
