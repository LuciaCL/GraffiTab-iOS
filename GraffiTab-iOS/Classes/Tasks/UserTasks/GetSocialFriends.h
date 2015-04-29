//
//  GetSocialFriends.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 27/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkTask.h"

@interface GetSocialFriends : NetworkTask

@property (nonatomic, assign) BOOL isStart;

- (void)getFriendsListWithIds:(NSArray *)ids start:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
