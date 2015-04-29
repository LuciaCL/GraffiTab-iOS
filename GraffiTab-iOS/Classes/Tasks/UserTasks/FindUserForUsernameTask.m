//
//  FindUserForUsernameTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 20/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "FindUserForUsernameTask.h"

@implementation FindUserForUsernameTask

- (void)findUserForUsername:(NSString *)username successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildFindUserForUsername];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_USER_USERNAME:username}];
    
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
    Person *p = [[Person alloc] initFromJson:json[JSON_RESP_USER_USER]];
    
    if ([p isEqual:[Settings getInstance].user])
        [[Settings getInstance] setUser:p];
    
    return p;
}

@end
