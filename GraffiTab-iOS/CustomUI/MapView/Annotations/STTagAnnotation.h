//
//  STTagAnnotation.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 19/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <JPSThumbnailAnnotation/JPSThumbnailAnnotation.h>

@interface STTagAnnotation : JPSThumbnailAnnotation

@property (nonatomic, strong) GTStreamableTag *item;

@end
