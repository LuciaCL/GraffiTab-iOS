//
//  MACreateStreamableCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "MACreateStreamableCell.h"

@implementation MACreateStreamableCell

+ (CGFloat)height {
    return 105;
}

- (void)setItem:(GTActivityContainer *)item {
    super.item = item;
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"MA_CREATE", nil), item.activityUser.fullName, item.activities.count];
    NSRange range = [text rangeOfString:item.activityUser.fullName];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_USERNAME) range:range];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.infoLabel.font.pointSize] range:range];
    
    self.infoLabel.attributedText = string;
    
    [self.itemsView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.item.activities.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MACell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    
    __weak typeof(UICollectionViewCell *) weakSelf = cell;
    
    GTActivityCreateStreamable *typedItem = (GTActivityCreateStreamable *)self.item.activities[indexPath.row];
    GTStreamable *streamable = typedItem.item;
    
    if (streamable.type == TAG) {
        GTStreamableTag *tag = (GTStreamableTag *)streamable;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetGraffiti:tag.graffitiId]]];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        [imageView setImageWithURLRequest:request placeholderImage:imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            UIImageView *imageView = (UIImageView *)[weakSelf viewWithTag:1];
            imageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            UIImageView *imageView = (UIImageView *)[weakSelf viewWithTag:1];
            imageView.image = nil;
        }];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int height = collectionView.frame.size.height;
    int width = height;
    
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

@end
