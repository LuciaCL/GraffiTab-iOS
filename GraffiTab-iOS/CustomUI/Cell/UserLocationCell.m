//
//  UserLocationCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "UserLocationCell.h"
#import "GoogleStaticApiUtils.h"

@implementation UserLocationCell

- (void)awakeFromNib {
    [self setupImageViews];
}

- (void)setSelected:(BOOL)selected {
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
    [self setSelectedBackgroundView:bgColorView];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *backgroundColor = self.locationImage.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.locationImage.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *backgroundColor = self.locationImage.backgroundColor;
    [super setSelected:selected animated:animated];
    self.locationImage.backgroundColor = backgroundColor;
}

- (void)setItem:(GTUserLocation *)item {
    _item = item;
    
    self.addressLabel.text = item.address;
    
    [self loadMap];
}

- (void)loadMap {
    __weak typeof(self) weakSelf = self;
    
    NSString *url = [GoogleStaticApiUtils getStaticMapUrlForLatitude:self.item.latitude longitude:self.item.longitude];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.locationImage.image = nil;
    [self.locationImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.locationImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.locationImage.image = nil;
    }];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.locationImage.layer.cornerRadius = 5;
    self.locationImage.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
}

@end
