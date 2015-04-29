//
//  SignUpTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "SignUpTask.h"

@implementation SignUpTask

- (void)signupWithUsername:(NSString *)username password:(NSString *)password email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName externalId:(NSString *)externalId successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildSignUp];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_USER_USERNAME:username,
                                                                                  JSON_REQ_GENERIC_EMAIL:email,
                                                                                  JSON_REQ_USER_FIRST_NAME:firstName,
                                                                                  JSON_REQ_USER_LAST_NAME:lastName}];
    
    if (externalId)
        params[JSON_REQ_USER_EXTERNAL_ID] = externalId;
    if (password)
        params[JSON_REQ_USER_PASSWORD] = password;
    
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
    
    [[Settings getInstance] setUser:p];
    
    return p;
}

@end
