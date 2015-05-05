//
//  ProfileAssetsCell.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 16/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ProfileAssetsCell.h"

@interface ProfileAssetsCell () {
    
    IBOutlet UIView *assets1View;
    IBOutlet UIView *assets2View;
    IBOutlet UIView *assets3View;
    IBOutlet UICollectionView *assetsCollection1;
    IBOutlet UICollectionView *assetsCollection2;
    IBOutlet UICollectionView *assetsCollection3;
    
    NSMutableArray *assets1Items;
    NSMutableArray *assets2Items;
    NSMutableArray *assets3Items;
}

@end

@implementation ProfileAssetsCell

+ (NSString *)reusableIdentifier {
    return @"ProfileAssetsCell";
}

+ (CGFloat)height {
    return 98;
}

- (void)awakeFromNib {
    // Initialization code
    assets1Items = [NSMutableArray new];
    assets2Items = [NSMutableArray new];
    assets3Items = [NSMutableArray new];
    
    [self setupAssetViews];
}

- (void)onClickGraffiti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapGraffiti)])
        [self.delegate didTapGraffiti];
}

- (void)onClickFollowers {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowers)])
        [self.delegate didTapFollowers];
}

- (void)onClickFollowing {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapFollowing)])
        [self.delegate didTapFollowing];
}

- (void)setItem:(GTPerson *)item {
    _item = item;
    
    [self loadAssets1];
    [self loadAssets2];
    [self loadAssets3];
}

#pragma mark - Loading

- (void)loadAssets1 {
    UIImage *errorImage = [UIImage imageNamed:@"gallery.png"];
    
    if (!self.item) {
        [self finishLoadingWithSuccess:assetsCollection1 containerView:assets1View errorImage:errorImage items:nil];
        return;
    }
    
    if (assets1Items && assets1Items.count > 0)
        return;
    
    [GTStreamableManager getItemsWithUserId:self.item.userId start:0 numberOfItems:6 useCache:YES successBlock:^(GTResponseObject *response) {
        assets1Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection1 containerView:assets1View errorImage:errorImage items:assets1Items];
    } cacheBlock:^(GTResponseObject *response) {
        assets1Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection1 containerView:assets1View errorImage:errorImage items:assets1Items];
    } failureBlock:^(GTResponseObject *response) {
        [self finishLoadingWithSuccess:assetsCollection1 containerView:assets1View errorImage:errorImage items:nil];
    }];
}

- (void)loadAssets2 {
    UIImage *errorImage = [UIImage imageNamed:@"group.png"];
    
    if (!self.item) {
        [self finishLoadingWithSuccess:assetsCollection2 containerView:assets2View errorImage:errorImage items:nil];
        return;
    }
    
    if (assets2Items && assets2Items.count > 0)
        return;
    
    [GTUserManager getFollowersWithUserId:self.item.userId start:0 numberOfItems:6 useCache:YES successBlock:^(GTResponseObject *response) {
        assets2Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection2 containerView:assets2View errorImage:errorImage items:assets2Items];
    } cacheBlock:^(GTResponseObject *response) {
        assets2Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection2 containerView:assets2View errorImage:errorImage items:assets2Items];
    } failureBlock:^(GTResponseObject *response) {
        [self finishLoadingWithSuccess:assetsCollection2 containerView:assets2View errorImage:errorImage items:nil];
    }];
}

- (void)loadAssets3 {
    UIImage *errorImage = [UIImage imageNamed:@"group.png"];
    
    if (!self.item) {
        [self finishLoadingWithSuccess:assetsCollection3 containerView:assets3View errorImage:errorImage items:nil];
        return;
    }
    
    if (assets2Items && assets2Items.count > 0)
        return;
    
    [GTUserManager getFollowingWithUserId:self.item.userId start:0 numberOfItems:6 useCache:YES successBlock:^(GTResponseObject *response) {
        assets3Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection3 containerView:assets3View errorImage:errorImage items:assets3Items];
    } cacheBlock:^(GTResponseObject *response) {
        assets3Items = response.object;
        
        [self finishLoadingWithSuccess:assetsCollection3 containerView:assets3View errorImage:errorImage items:assets3Items];
    } failureBlock:^(GTResponseObject *response) {
        [self finishLoadingWithSuccess:assetsCollection3 containerView:assets3View errorImage:errorImage items:nil];
    }];
}

- (void)finishLoadingWithSuccess:(UICollectionView *)assetsCollection containerView:(UIView *)container errorImage:(UIImage *)errorImage items:(NSMutableArray *)items {
    [assetsCollection reloadData];
    
    if (!items || items.count <= 0) {
        UIImageView *errorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        errorView.image = [errorImage imageWithTint:UIColorFromRGB(0xB7C0D8)];
        errorView.tag = 123;
        errorView.center = assetsCollection.center;
        [container addSubview:errorView];
    }
    else
        [[container viewWithTag:123] removeFromSuperview];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == assetsCollection1)
        return assets1Items.count;
    if (collectionView == assetsCollection2)
        return assets2Items.count;
    if (collectionView == assetsCollection3)
        return assets3Items.count;
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetsImageCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    
    if (collectionView == assetsCollection1) {
        __weak typeof(UICollectionViewCell *) weakSelf = cell;
        GTStreamable *streamable = (GTStreamable *)assets1Items[indexPath.row];
        
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
    }
    else if (collectionView == assetsCollection2 || collectionView == assetsCollection3) {
        __weak typeof(UICollectionViewCell *) weakSelf = cell;
        GTPerson *user = (GTPerson *)(collectionView == assetsCollection2 ? assets2Items[indexPath.row] : assets3Items[indexPath.row]);
        
        if (user.avatarId > 0) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetAvatar:user.avatarId]]];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            
            [imageView setImageWithURLRequest:request placeholderImage:imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                UIImageView *imageView = (UIImageView *)[weakSelf viewWithTag:1];
                imageView.image = image;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                UIImageView *imageView = (UIImageView *)[weakSelf viewWithTag:1];
                imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
            }];
        }
        else
            imageView.image = [UIImage imageNamed:@"default_avatar.jpg"];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width = collectionView.frame.size.width / 3;
    int height = collectionView.frame.size.height / 2;
    
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

#pragma mark - Setup

- (void)setupAssetViews {
    assets1View.layer.cornerRadius = 5;
    assets2View.layer.cornerRadius = 5;
    assets3View.layer.cornerRadius = 5;
    
    [assets1View addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickGraffiti)]];
    [assets2View addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFollowers)]];
    [assets3View addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFollowing)]];
}

@end
