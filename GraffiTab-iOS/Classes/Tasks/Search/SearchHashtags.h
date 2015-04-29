//
//  SearchHashtags.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface SearchHashtags : NetworkTask

- (void)searchHashtagsWithQuery:(NSString *)q offset:(int)start numberOfItems:(int)count successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
