//
//  STFullSizeTableCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STFullSizeTableCellFactory.h"

@implementation STFullSizeTableCellFactory

+ (STFullSizeTableCell *)createStreamableTableCellForStreamable:(GTStreamable *)streamable tableView:(UITableView *)collectionView indexPath:(NSIndexPath *)indexPath {
    StreamableType type = streamable.type;
    STFullSizeTableCell *cell;
    
    if (type == TAG)
        cell = [collectionView dequeueReusableCellWithIdentifier:[STTagFullSizeTableCell reusableIdentifier] forIndexPath:indexPath];
    else if (type == VIDEO)
        cell = [collectionView dequeueReusableCellWithIdentifier:[STVideoFullSizeTableCell reusableIdentifier] forIndexPath:indexPath];
    
    cell.item = streamable;
    
    return cell;
}

@end
