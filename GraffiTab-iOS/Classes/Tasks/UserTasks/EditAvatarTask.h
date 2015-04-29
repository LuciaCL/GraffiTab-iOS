//
//  EditAvatarTask.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 27/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NetworkTask.h"

@interface EditAvatarTask : NetworkTask

- (void)editAvatarWithNewImage:(UIImage *)image successBlock:(void (^)(ResponseObject *))successBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
