//
//  CreateStreamableTagTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface CreateStreamableTagTask : NetworkTask

- (void)createTagWithImage:(UIImage *)image location:(CLLocation *)location successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
