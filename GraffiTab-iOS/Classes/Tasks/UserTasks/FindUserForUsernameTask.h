//
//  FindUserForUsernameTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 20/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface FindUserForUsernameTask : NetworkTask

- (void)findUserForUsername:(NSString *)username successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
