//
//  SearchGraffitiViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STThumbnailOnlyViewController.h"

@interface SearchGraffitiViewController : STThumbnailOnlyViewController

@property (nonatomic, copy) NSString *searchString;

- (void)setSearchHashtag:(NSString *)hashtag;

@end
