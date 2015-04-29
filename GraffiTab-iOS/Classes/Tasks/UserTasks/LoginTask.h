//
//  LoginTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkTask.h"

@interface LoginTask : NetworkTask

- (void)loginWithUsername:(NSString *)username password:(NSString *)password successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
