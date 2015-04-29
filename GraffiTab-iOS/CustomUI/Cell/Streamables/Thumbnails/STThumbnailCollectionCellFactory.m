//
//  STThumbnailCollectionCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "STThumbnailCollectionCellFactory.h"

@implementation STThumbnailCollectionCellFactory

+ (STThumbnailCollectionCell *)createStreamableCollectionCellForStreamable:(Streamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    StreamableType type = streamable.type;
    STThumbnailCollectionCell *cell;
    
    if (type == TAG)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STTagThumbnailCollectionCell reusableIdentifier] forIndexPath:indexPath];
    else if (type == VIDEO)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STVideoThumbnailCollectionCell reusableIdentifier] forIndexPath:indexPath];
    
    cell.item = streamable;
    
    return cell;
}

@end
