//
//  ResetPasswordTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkTask.h"

@interface ResetPasswordTask : NetworkTask

- (void)resetPasswordWithEmail:(NSString *)email successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
