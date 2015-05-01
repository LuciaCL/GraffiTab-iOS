//
//  STThumbnailCollectionCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STThumbnailCollectionCell.h"
#import "STTagThumbnailCollectionCell.h"
#import "STVideoThumbnailCollectionCell.h"

@interface STThumbnailCollectionCellFactory : NSObject

+ (STThumbnailCollectionCell *)createStreamableCollectionCellForStreamable:(GTStreamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
