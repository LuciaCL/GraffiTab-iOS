//
//  STMediumCollectionCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STMediumCollectionCellFactory.h"

@implementation STMediumCollectionCellFactory

+ (STMediumCollectionCell *)createStreamableCollectionCellForStreamable:(Streamable *)streamable tableView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    StreamableType type = streamable.type;
    STMediumCollectionCell *cell;
    
    if (type == TAG)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STTagMediumCollectionCell reusableIdentifier] forIndexPath:indexPath];
    else if (type == VIDEO)
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:[STVideoMediumCollectionCell reusableIdentifier] forIndexPath:indexPath];
    
    cell.item = streamable;
    
    return cell;
}

@end
