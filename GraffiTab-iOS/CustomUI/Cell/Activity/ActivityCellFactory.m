//
//  ActivityCellFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ActivityCellFactory.h"

@implementation ActivityCellFactory

+ (ActivityCell *)createActivityCellForActivityContainer:(GTActivityContainer *)activityContainer tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    ActivityType type = activityContainer.type;
    ActivityCell *cell;
    
    if (activityContainer.activities.count == 1) { // Load single activity cells.
        if (type == ACTIVITY_COMMENT)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SACommentCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_CREATE_STREAMABLE)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SACreateStreamableCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_FOLLOW)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SAFollowCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_LIKE)
            cell = [tableView dequeueReusableCellWithIdentifier:@"SALikeCell" forIndexPath:indexPath];
    }
    else {
        if (type == ACTIVITY_COMMENT)
            cell = [tableView dequeueReusableCellWithIdentifier:@"MACommentCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_CREATE_STREAMABLE)
            cell = [tableView dequeueReusableCellWithIdentifier:@"MACreateStreamableCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_FOLLOW)
            cell = [tableView dequeueReusableCellWithIdentifier:@"MAFollowCell" forIndexPath:indexPath];
        else if (type == ACTIVITY_LIKE)
            cell = [tableView dequeueReusableCellWithIdentifier:@"MALikeCell" forIndexPath:indexPath];
    }
    
    cell.item = activityContainer;
    
    return cell;
}

+ (CGFloat)cellHeightForActivityContainer:(GTActivityContainer *)activityContainer tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    ActivityType type = activityContainer.type;
    CGFloat h = tableView.rowHeight;
    
    if (activityContainer.activities.count == 1) { // Load single activity cells.
        if (type == ACTIVITY_COMMENT)
            h = [SACommentCell height];
        else if (type == ACTIVITY_CREATE_STREAMABLE)
            h = [SACreateStreamableCell height];
        else if (type == ACTIVITY_FOLLOW)
            h = [SAFollowCell height];
        else if (type == ACTIVITY_LIKE)
            h = [SALikeCell height];
    }
    else {
        if (type == ACTIVITY_COMMENT)
            h = [MACommentCell height];
        else if (type == ACTIVITY_CREATE_STREAMABLE)
            h = [MACreateStreamableCell height];
        else if (type == ACTIVITY_FOLLOW)
            h = [MAFollowCell height];
        else if (type == ACTIVITY_LIKE)
            h = [MALikeCell height];
    }
    
    return h;
}

@end
