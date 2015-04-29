//
//  RegisterDeviceTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface RegisterDeviceTask : NetworkTask

- (void)registerDeviceWithToken:(NSString *)token successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
