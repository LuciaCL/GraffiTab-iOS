//
//  Streamable.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TAG,
    VIDEO
} StreamableType;

#define STREAMABLE_TYPE_LIST @[@"TAG", @"VIDEO"]

#define StreamableType(str) (StreamableType)[STREAMABLE_TYPE_LIST indexOfObject:str]

@interface Streamable : NSObject <JSONSerializable>

@property (nonatomic, assign) long streamableId;
@property (nonatomic, strong) Person *user;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) StreamableType type;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL isFlagged;
@property (nonatomic, assign) int likesCount;
@property (nonatomic, assign) int commentsCount;
@property (nonatomic, assign) BOOL isLiked;

- (id)initFromJson:(NSDictionary *)json;

@end
