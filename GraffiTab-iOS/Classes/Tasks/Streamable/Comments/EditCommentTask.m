//
//  EditCommentTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 29/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "EditCommentTask.h"

@implementation EditCommentTask

- (void)editCommentWithId:(long)commentId text:(NSString *)text successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildEditComment];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_COMMENT_ID:@(commentId),
                                                                                  JSON_REQ_GENERIC_TEXT:text}];
    
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
}

- (id)parseJsonSuccessObject:(NSDictionary *)json {
    Comment *p = [[Comment alloc] initFromJson:json[JSON_RESP_COMMENT_COMMENT]];
    
    return p;
}

@end
