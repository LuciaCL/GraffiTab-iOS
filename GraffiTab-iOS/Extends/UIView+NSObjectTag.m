//
//  UIView+NSObjectTag.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 21/10/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "UIView+NSObjectTag.h"
#import <objc/runtime.h>

static char const *const ObjectTagKey = "ObjectTag";

@implementation UIView (ObjectTagAdditions)

@dynamic objectTag;

- (id)objectTag {
    return objc_getAssociatedObject(self, ObjectTagKey);
}

- (void)setObjectTag:(id)newObjectTag {
    objc_setAssociatedObject(self, ObjectTagKey, newObjectTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
