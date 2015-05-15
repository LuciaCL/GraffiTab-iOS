//
//  CreditsLibrary.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CreditsLibrary.h"

@implementation CreditsLibrary

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.title = json[@"title"];
        self.url = json[@"url"];
    }
    
    return self;
}

@end
