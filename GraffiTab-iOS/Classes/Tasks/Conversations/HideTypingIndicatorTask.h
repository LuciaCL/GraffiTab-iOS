//
//  HideTypingIndicatorTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 07/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface HideTypingIndicatorTask : NetworkTask

- (void)hideTypingIndicatorForConversationId:(long)conversationId successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
