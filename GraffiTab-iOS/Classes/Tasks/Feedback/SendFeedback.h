//
//  SendFeedback.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface SendFeedback : NetworkTask

- (void)postFeedbackWithText:(NSString *)text successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
