//
//  StreamableTag.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "StreamableTag.h"

@implementation StreamableTag

- (id)initFromJson:(NSDictionary *)json {
    self = [super initFromJson:json];
    
    if (self) {
        self.graffitiId = [json[JSON_STREAMABLE_TAG_GRAFFITIID] longValue];
        self.latitude = [json[JSON_STREAMABLE_TAG_LATITUDE] doubleValue];
        self.longitude = [json[JSON_STREAMABLE_TAG_LONGITUDE] doubleValue];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super asDictionary]];
    
    json[JSON_STREAMABLE_TAG_GRAFFITIID] = @(self.graffitiId);
    json[JSON_STREAMABLE_TAG_LATITUDE] = @(self.latitude);
    json[JSON_STREAMABLE_TAG_LONGITUDE] = @(self.longitude);
    
    return json;
}

@end
