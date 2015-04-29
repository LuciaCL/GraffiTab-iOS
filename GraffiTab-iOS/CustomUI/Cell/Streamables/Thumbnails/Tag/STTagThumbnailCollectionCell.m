//
//  STTagThumbnailCollectionCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "STTagThumbnailCollectionCell.h"

@interface STTagThumbnailCollectionCell () {
    
    StreamableTag *typedItem;
}

@end

@implementation STTagThumbnailCollectionCell

+ (NSString *)reusableIdentifier {
    return @"STTagThumbnailCollectionCell";
}

- (void)setItem:(Streamable *)item {
    super.item = item;
    
    typedItem = (StreamableTag *)item;
    
    [self loadItem];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[RequestBuilder buildGetGraffiti:typedItem.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.itemImage.image = nil;
    [self.itemImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.itemImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.itemImage.image = nil;
    }];
}

@end
