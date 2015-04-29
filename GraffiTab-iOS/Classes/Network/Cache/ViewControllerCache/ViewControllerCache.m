//
//  ViewControllerCache.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/10/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "ViewControllerCache.h"

@implementation ViewControllerCache

static ViewControllerCache *sharedInstance;

+ (ViewControllerCache *)instance {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{ sharedInstance = [self new]; });
    }
    
    return sharedInstance;
}

- (void)addDataEntryToVCCache:(NSString *)vcName withContentId:(NSString *)contentId data:(NSString *)data {
    NSString *entryId = [NSString stringWithFormat:@"%@_%@", vcName, contentId];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:entryId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)checkVCCache:(NSString *)vcName withContentId:(NSString *)contentId {
    NSString *entryId = [NSString stringWithFormat:@"%@_%@", vcName, contentId];
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:entryId];
}

@end
