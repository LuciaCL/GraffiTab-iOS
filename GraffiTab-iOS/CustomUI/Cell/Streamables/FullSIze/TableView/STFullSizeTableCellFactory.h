//
//  STFullSizeTableCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFullSizeTableCell.h"
#import "STTagFullSizeTableCell.h"
#import "STVideoFullSizeTableCell.h"

@interface STFullSizeTableCellFactory : NSObject

+ (STFullSizeTableCell *)createStreamableTableCellForStreamable:(GTStreamable *)streamable tableView:(UITableView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
