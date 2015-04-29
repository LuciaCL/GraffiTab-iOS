//
//  StreamableFactory.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "StreamableFactory.h"

@implementation StreamableFactory

+ (Streamable *)createStreamableFromJson:(NSDictionary *)json {
    StreamableType type = StreamableType(json[JSON_STREAMABLE_TYPE]);
    
    if (type == TAG)
        return [[StreamableTag alloc] initFromJson:json];
    else if (type == VIDEO)
        return [[StreamableVideo alloc] initFromJson:json];
    else
        return [[Streamable alloc] initFromJson:json];
}

@end
