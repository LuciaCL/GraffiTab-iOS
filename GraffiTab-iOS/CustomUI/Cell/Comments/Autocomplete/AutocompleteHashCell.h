//
//  AutocompleteHashCell.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutocompleteHashCell : UITableViewCell

@property (nonatomic, weak) NSString *item;
@property (nonatomic, weak) IBOutlet UILabel *hashLabel;

+ (CGFloat)height;

@end
