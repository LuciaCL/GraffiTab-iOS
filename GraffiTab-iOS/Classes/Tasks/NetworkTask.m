//
//  NetworkTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@implementation NetworkTask

- (id)init {
    self = [super init];
    
    if (self) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    
    return self;
}

- (void)parseJsonSuccess:(NSDictionary *)json {
    ResponseObject *response = [ResponseObject new];
    response.result = SUCCESS;
    response.object = [self parseJsonSuccessObject:json];
    
    [self finishRequestWithResponse:response];
}

- (void)parseJsonCacheSuccess:(NSDictionary *)json {
    ResponseObject *response = [ResponseObject new];
    response.result = SUCCESS;
    response.object = [self parseJsonSuccessObject:json];
    
    [self finishCachedRequestWithResponse:response];
}

- (void)parseJsonError:(NSDictionary *)json {
    ResponseObject *response = [ResponseObject new];
    response.result = ERROR;
    
    @try {
        if (!json) {
            response.reason = NETWORK;
            response.message = @"Network error. Please check your connection and try again.";
        }
        else {
            response.reason = Reason(json[JSON_RESP_GENERIC_ERROR_TYPE]);
            response.message = json[JSON_RESP_GENERIC_ERROR_MESSAGE];
        }
    }
    @catch (NSException *exception) {
        response.reason = NETWORK;
        response.message = @"Network error. Please check your connection and try again.";
    }

    [self finishRequestWithResponse:response];
}

- (id)parseJsonSuccessObject:(NSDictionary *)json {
    return nil;
}

- (void)finishRequestWithResponse:(ResponseObject *)response {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [CookieManager saveCookies];
    
    if (response.result == SUCCESS)
        self.sBlock(response);
    else {
        NSLog(@"ERROR (%@) MESSAGE - %@", REASON_LIST[response.reason], response.message);
        
        self.fBlock(response);
    }
}

- (void)finishCachedRequestWithResponse:(ResponseObject *)response {
    [CookieManager saveCookies];
    
    self.cBlock(response);
}

@end
