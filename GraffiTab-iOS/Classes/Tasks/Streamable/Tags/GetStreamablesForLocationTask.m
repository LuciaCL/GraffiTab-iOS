//
//  GetStreamablesForLocationTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 19/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "GetStreamablesForLocationTask.h"

@implementation GetStreamablesForLocationTask

- (void)getForLocationWithNECoordinate:(CLLocationCoordinate2D)neCoordinate SWCoordinate:(CLLocationCoordinate2D)swCoordinate start:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    self.cBlock = cacheBlock;
    
    NSString *string = [RequestBuilder buildGetItemsForLocation];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_STREAMABLE_TAG_NE_LATITUDE:@(neCoordinate.latitude),
                                                                                  JSON_REQ_STREAMABLE_TAG_NE_LONGITUDE:@(neCoordinate.longitude),
                                                                                  JSON_REQ_STREAMABLE_TAG_SW_LATITUDE:@(swCoordinate.latitude),
                                                                                  JSON_REQ_STREAMABLE_TAG_SW_LONGITUDE:@(swCoordinate.longitude),
                                                                                  JSON_REQ_GENERIC_OFFSET:@(start),
                                                                                  JSON_REQ_GENERIC_NUM_ITEMS:@(count)}];
    
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
    
    if (self.isStart) {
        SessionManager.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
        
        [SessionManager.manager POST:string parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseJson = responseObject;
            
            [self parseJsonCacheSuccess:responseJson];
            
            // Load second request.
            simpleBlock();
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            simpleBlock();
        }];
    }
    else
        simpleBlock();
}

- (id)parseJsonSuccessObject:(NSDictionary *)json {
    NSArray *jsonArray = json[JSON_RESP_GENERIC_ITEMS];
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSDictionary *itemJson in jsonArray) {
        Streamable *n = [StreamableFactory createStreamableFromJson:itemJson];
        
        [items addObject:n];
    }
    
    return items;
}

@end
