//
//  VerifyExternalUserTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 27/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkTask.h"

@interface VerifyExternalUserTask : NetworkTask

- (void)verifyUserWithExternalId:(NSString *)externalId successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
