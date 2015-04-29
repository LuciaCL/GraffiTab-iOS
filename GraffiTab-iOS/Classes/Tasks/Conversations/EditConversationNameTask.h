//
//  EditConversationNameTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 13/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface EditConversationNameTask : NetworkTask

- (void)editConversationTitleWithId:(long)conversationId text:(NSString *)text successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
