//
//  EditPasswordTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 18/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface EditPasswordTask : NetworkTask

- (void)editProfileWithPassword:(NSString *)password newPassword:(NSString *)newPassword successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
