//
//  STFullSizeCollectionCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFullSizeCollectionCell.h"
#import "STTagFullSizeCollectionCell.h"
#import "STVideoFullSizeCollectionCell.h"

@interface STFullSizeCollectionCellFactory : NSObject

+ (STFullSizeCollectionCell *)createStreamableCollectionCellForStreamable:(GTStreamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
