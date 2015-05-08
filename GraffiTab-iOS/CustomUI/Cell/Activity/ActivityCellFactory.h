//
//  ActivityCellFactory.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityCell.h"
#import "SACommentCell.h"
#import "SACreateStreamableCell.h"
#import "SAFollowCell.h"
#import "SALikeCell.h"
#import "MACommentCell.h"
#import "MACreateStreamableCell.h"
#import "MAFollowCell.h"
#import "MALikeCell.h"

@interface ActivityCellFactory : NSObject

+ (ActivityCell *)createActivityCellForActivityContainer:(GTActivityContainer *)activityContainer tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)cellHeightForActivityContainer:(GTActivityContainer *)activityContainer tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
