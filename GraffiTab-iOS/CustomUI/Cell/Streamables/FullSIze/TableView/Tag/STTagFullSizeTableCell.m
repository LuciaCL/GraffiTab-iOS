//
//  STTagFullSizeTableCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STTagFullSizeTableCell.h"

@interface STTagFullSizeTableCell () {
    
    GTStreamableTag *typedItem;
}

@end

@implementation STTagFullSizeTableCell

+ (NSString *)reusableIdentifier {
    return @"STTagFullSizeTableCell";
}

+ (CGFloat)height {
    return 464;
}

- (void)setItem:(GTStreamable *)item {
    super.item = item;
    
    typedItem = (GTStreamableTag *)item;
    
    [self loadItem];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetFullGraffiti:typedItem.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.itemImage.image = nil;
    [self.itemImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.itemImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.itemImage.image = nil;
    }];
}

@end
