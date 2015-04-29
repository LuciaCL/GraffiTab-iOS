//
//  Person.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Person : NSObject <JSONSerializable>

// Fields for basic user profile.
@property (nonatomic, assign) long userId;
@property (nonatomic, copy) NSString *externalId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *about;
@property (nonatomic, assign) long avatarId;
@property (nonatomic, assign) long coverId;

// Fields for full user profile.
@property (nonatomic, assign) int followersCount;
@property (nonatomic, assign) int followeesCount;
@property (nonatomic, assign) int streamablesCount;
@property (nonatomic, assign) BOOL isFollowing;

- (id)initFromJson:(NSDictionary *)json;

- (NSString *)fullName;
- (NSString *)mentionUsername;
- (NSString *)streamablesCountAsString;
- (NSString *)followersCountAsString;
- (NSString *)followingCountAsString;
- (NSString *)aboutString;

@end
