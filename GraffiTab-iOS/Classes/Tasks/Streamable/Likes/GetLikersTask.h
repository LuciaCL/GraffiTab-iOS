//
//  GetLikersTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface GetLikersTask : NetworkTask

@property (nonatomic, assign) BOOL isStart;

- (void)getLikersWithItemId:(long)itemId start:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
