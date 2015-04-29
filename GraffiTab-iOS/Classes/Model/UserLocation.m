//
//  UserLocation.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "UserLocation.h"

@implementation UserLocation

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.locationId = [json[JSON_USER_LOCATION_ID] longValue];
        self.user = [[Person alloc] initFromJson:json[JSON_USER_LOCATION_USER]];
        self.address = json[JSON_USER_LOCATION_ADDRESS];
        self.latitude = [json[JSON_USER_LOCATION_LATITUDE] doubleValue];
        self.longitude = [json[JSON_USER_LOCATION_LONGITUDE] doubleValue];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_USER_LOCATION_ID] = @(self.locationId);
    json[JSON_USER_LOCATION_USER] = self.user.asDictionary;
    json[JSON_USER_LOCATION_ADDRESS] = self.address;
    json[JSON_USER_LOCATION_LATITUDE] = @(self.latitude);
    json[JSON_USER_LOCATION_LONGITUDE] = @(self.longitude);
    
    return json;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(UserLocation *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.locationId != aWidget.locationId)
        return NO;
    return YES;
}

@end
