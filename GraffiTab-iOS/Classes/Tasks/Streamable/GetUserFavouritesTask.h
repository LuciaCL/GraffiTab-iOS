//
//  GetUserFavouritesTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface GetUserFavouritesTask : NetworkTask

@property (nonatomic, assign) BOOL isStart;

- (void)getFavouriteItemsWithUserId:(long)userId start:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
