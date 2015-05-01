//
//  STVideoMediumCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STVideoMediumCollectionCell.h"

@interface STVideoMediumCollectionCell () {
    
    GTStreamableVideo *typedItem;
}

@end

@implementation STVideoMediumCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STVideoMediumCollectionCell";
}

- (void)setItem:(GTStreamable *)item {
    super.item = item;
    
    typedItem = (GTStreamableVideo *)item;
}

@end
