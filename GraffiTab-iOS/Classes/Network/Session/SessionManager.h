//
//  SessionManager.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "JSONResponseSerializerWithData.h"

@interface SessionManager : AFHTTPSessionManager

+ (SessionManager *)manager;

@end
