//
//  ViewControllerCache.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/10/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewControllerCache : NSObject

+ (ViewControllerCache *)instance;

- (void)addDataEntryToVCCache:(NSString *)vcName withContentId:(NSString *)contentId data:(NSString *)data;
- (NSString *)checkVCCache:(NSString *)vcName withContentId:(NSString *)contentId;

@end
