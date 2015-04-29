//
//  SearchHashtag.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface SearchHashtag : NetworkTask

- (void)searchHashtagWithQuery:(NSString *)q offset:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
