//
//  PostCommentTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 28/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface PostCommentTask : NetworkTask

- (void)postCommentWithText:(NSString *)text itemId:(long)itemId successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
