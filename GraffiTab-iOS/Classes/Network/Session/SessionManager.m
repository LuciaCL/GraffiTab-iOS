//
//  SessionManager.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

static SessionManager *manager;

+ (SessionManager *)manager {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:API_APP_URL]];
            
            manager.responseSerializer = [JSONResponseSerializerWithData serializer];
            manager.requestSerializer = [AFJSONRequestSerializer new];
        });
    }
    
    return manager;
}

@end
