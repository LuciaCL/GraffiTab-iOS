//
//  STThumbnailCollectionCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STThumbnailCollectionCell : UICollectionViewCell

@property (nonatomic, weak) Streamable *item;
@property (nonatomic, weak) IBOutlet UIImageView *itemImage;

+ (NSString *)reusableIdentifier;

@end
