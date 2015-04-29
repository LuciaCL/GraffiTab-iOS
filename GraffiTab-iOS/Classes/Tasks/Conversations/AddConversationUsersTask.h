//
//  AddConversationUsersTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 13/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface AddConversationUsersTask : NetworkTask

- (void)addConversationUsersWithConversationId:(long)conversationId receiverIds:(NSMutableArray *)receiverIds successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
