//
//  EditProfileTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "EditProfileTask.h"

@implementation EditProfileTask

- (void)editProfileWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email about:(NSString *)about website:(NSString *)website successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildEditProfile];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_USER_FIRST_NAME:firstName,
                                                                                  JSON_REQ_USER_LAST_NAME:lastName,
                                                                                  JSON_REQ_GENERIC_EMAIL:email}];
    
    if (about && about.length > 0)
        params[JSON_REQ_USER_ABOUT] = about;
    if (website && website.length > 0)
        params[JSON_REQ_USER_WEBSITE] = website;
    
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
