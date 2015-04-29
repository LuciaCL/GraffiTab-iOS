//
//  CreateConversationTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CreateConversationTask.h"

@implementation CreateConversationTask

- (void)createConversationWithText:(NSString *)msg title:(NSString *)title receiverIds:(NSMutableArray *)receiverIds image:(UIImage *)image successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *string = [RequestBuilder buildCreateConversation];
        
        NSString *encodedString;
        if (image) {
            NSData *imageData = UIImageJPEGRepresentation(image, COMPRESSION_QUALITY);
            encodedString = [imageData base64EncodedStringWithOptions:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_CONVERSATION_RECEIVER_IDS:receiverIds,
                                                                                          JSON_REQ_GENERIC_TEXT:msg}];
            
            if (title)
                params[JSON_REQ_CONVERSATION_TITLE] = title;
            if (encodedString)
                params[JSON_REQ_GENERIC_ENCODED_IMAGE] = encodedString;
            
            SessionManager.manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            
            [SessionManager.manager POST:string parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *responseJson = responseObject;
                
                [self parseJsonSuccess:responseJson];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (error.userInfo[JSONResponseSerializerWithDataKey]) {
                    NSData *data = error.userInfo[JSONResponseSerializerWithDataKey];
                    
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&error];
                    
                    [self parseJsonError:json];
                }
                else
                    [self parseJsonError:nil];
            }];
        });
    });
}

- (id)parseJsonSuccessObject:(NSDictionary *)json {
    Conversation *p = [[Conversation alloc] initFromJson:json[JSON_RESP_CONVERSATION_CONVERSATION]];
    
    return p;
}

@end
