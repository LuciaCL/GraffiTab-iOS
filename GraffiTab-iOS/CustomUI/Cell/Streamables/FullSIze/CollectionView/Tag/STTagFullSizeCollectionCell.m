//
//  STTagFullSizeCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STTagFullSizeCollectionCell.h"

@interface STTagFullSizeCollectionCell () {
    
    StreamableTag *typedItem;
}

@end

@implementation STTagFullSizeCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STTagFullSizeCollectionCell";
}

+ (CGFloat)height {
    return 464;
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableTag *)item;
    
    [self loadItem];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetFullGraffiti:typedItem.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.itemImage.image = nil;
    [self.itemImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.itemImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.itemImage.image = nil;
    }];
}

@end