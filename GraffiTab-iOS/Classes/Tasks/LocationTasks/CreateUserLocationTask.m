//
//  CreateUserLocationTask.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "CreateUserLocationTask.h"
#import <AddressBookUI/AddressBookUI.h>

@implementation CreateUserLocationTask

- (void)createLocationWithPlacemark:(CLPlacemark *)placemark successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    self.sBlock = successBlock;
    self.fBlock = failureBlock;
    
    NSString *string = [RequestBuilder buildCreateUserLocation];
    
    NSString *addressTxt = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    NSString *newString = [[addressTxt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@", "];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{JSON_REQ_LOCATION_ADDRESS:newString,
                                                                                  JSON_REQ_GENERIC_LATITUDE:@(placemark.location.coordinate.latitude),
                                                                                  JSON_REQ_GENERIC_LONGITUDE:@(placemark.location.coordinate.longitude)}];
    
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
    UserLocation *p = [[UserLocation alloc] initFromJson:json[JSON_RESP_LOCATION_LOCATION]];
    
    return p;
}

@end
