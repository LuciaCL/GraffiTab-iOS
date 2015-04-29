//
//  LogoutTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "LogoutTask.h"
#import "UnregisterDeviceTask.h"

@implementation LogoutTask

- (void)logoutWithSuccessBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    // Try unregistering the user's device first.
    NSString *token = [Settings getInstance].token;
    
    UnregisterDeviceTask *task = [UnregisterDeviceTask new];
    [task unregisterDeviceWithToken:token successBlock:^(ResponseObject *response) {
        NSLog(@"Token unregistered");
        
        // After the token has been succesfully unregistered, logout the user.
        NSString *string = [RequestBuilder buildLogout];
        
        [SessionManager.manager GET:string parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseJson = responseObject;
            
            [self parseJsonSuccess:responseJson];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self processError:error];
        }];
    } failureBlock:^(ResponseObject *response) {
        NSLog(@"Failed to unregister token");
        
        [self processError:nil];
    }];
}

- (void)processError:(NSError *)error {
    if (error.userInfo[JSONResponseSerializerWithDataKey]) {
        NSData *data = error.userInfo[JSONResponseSerializerWithDataKey];
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        [self parseJsonError:json];
    }
    else
        [self parseJsonError:nil];
}

@end
