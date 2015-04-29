//
//  DeleteMessagesTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface DeleteMessagesTask : NetworkTask

- (void)deleteMessages:(NSMutableArray *)ids successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
