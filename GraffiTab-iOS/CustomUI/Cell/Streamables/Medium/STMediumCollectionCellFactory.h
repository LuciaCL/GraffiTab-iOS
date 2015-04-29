//
//  STMediumCollectionCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMediumCollectionCell.h"
#import "STTagMediumCollectionCell.h"
#import "STVideoMediumCollectionCell.h"

@interface STMediumCollectionCellFactory : NSObject

+ (STMediumCollectionCell *)createStreamableCollectionCellForStreamable:(Streamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
