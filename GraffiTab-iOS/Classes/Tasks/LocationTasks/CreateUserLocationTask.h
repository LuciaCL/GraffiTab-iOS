//
//  CreateUserLocationTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface CreateUserLocationTask : NetworkTask

- (void)createLocationWithPlacemark:(CLPlacemark *)placemark successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
