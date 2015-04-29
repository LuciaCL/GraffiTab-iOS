//
//  StreamableVideo.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "StreamableVideo.h"

@implementation StreamableVideo

- (id)initFromJson:(NSDictionary *)json {
    self = [super initFromJson:json];
    
    if (self) {
        self.videoId = [json[JSON_STREAMABLE_VIDEO_VIDEOID] longValue];
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:[super asDictionary]];
    
    json[JSON_STREAMABLE_VIDEO_VIDEOID] = @(self.videoId);
    
    return json;
}

@end
