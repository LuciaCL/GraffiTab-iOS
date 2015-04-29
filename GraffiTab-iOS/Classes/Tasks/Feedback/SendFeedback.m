//
//  SendFeedback.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SendFeedback.h"

@implementation SendFeedback

- (void)postFeedbackWithText:(NSString *)text successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildPostFeedback];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_FEEDBACK_NAME:[Settings getInstance].user.fullName,
                                                                                  JSON_REQ_GENERIC_EMAIL:[Settings getInstance].user.email,
                                                                                  JSON_REQ_GENERIC_TEXT:text}];
    
    // Define web request.
    void (^simpleBlock)(void) = ^{
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
    };
    
    simpleBlock();
}

@end
