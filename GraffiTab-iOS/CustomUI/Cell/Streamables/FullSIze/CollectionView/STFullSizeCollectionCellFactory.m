//
//  STFullSizeCollectionCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STFullSizeCollectionCellFactory.h"

@implementation STFullSizeCollectionCellFactory

+ (STFullSizeCollectionCell *)createStreamableCollectionCellForStreamable:(Streamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    StreamableType type = streamable.type;
    STFullSizeCollectionCell *cell;
    
    if (type == TAG)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STTagFullSizeCollectionCell reusableIdentifier] forIndexPath:indexPath];
    else if (type == VIDEO)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STVideoFullSizeCollectionCell reusableIdentifier] forIndexPath:indexPath];
    
    cell.item = streamable;
    
    return cell;
}

@end
