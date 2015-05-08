//
//  SACommentCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SACommentCell.h"

@interface SACommentCell () {
    
    GTActivityComment *typedItem;
}

@end

@implementation SACommentCell

+ (CGFloat)height {
    return 80;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupImageViews];
}

- (void)setItem:(GTActivityContainer *)item {
    super.item = item;
    
    typedItem = (GTActivityComment *)item.activities.firstObject;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"SA_COMMENT", nil), item.activityUser.fullName];
    NSRange range = [text rangeOfString:item.activityUser.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
    
    if ([typedItem.item isKindOfClass:[GTStreamableTag class]]) // Load image only if we have a tag.
        [self loadItem];
}

- (void)loadItem {
    __weak typeof(self) weakSelf = self;
    
    GTStreamableTag *tag = (GTStreamableTag *) typedItem.item;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetGraffiti:tag.graffitiId]]];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    self.itemImage.image = nil;
    [self.itemImage setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.itemImage.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.itemImage.image = nil;
    }];
}

#pragma mark - Setup

- (void)setupImageViews {
    self.itemImage.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
}

@end
