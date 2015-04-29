//
//  Person.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Person.h"

@implementation Person

- (id)initFromJson:(NSDictionary *)json {
    self = [super init];
    
    if (self) {
        self.userId = [json[JSON_PERSON_ID] longValue];
        self.externalId = json[JSON_PERSON_EXTERNAL_ID];
        self.username = json[JSON_PERSON_USERNAME];
        self.firstname = json[JSON_PERSON_FIRSTNAME];
        self.lastname = json[JSON_PERSON_LASTNAME];
        self.username = json[JSON_PERSON_USERNAME];
        self.email = json[JSON_PERSON_EMAIL];
        self.website = json[JSON_PERSON_WEBSITE];
        self.about = json[JSON_PERSON_ABOUT];
        self.avatarId = [json[JSON_PERSON_AVATAR_ID] longValue];
        self.coverId = [json[JSON_PERSON_COVER_ID] longValue];
        
        self.followersCount = [json[JSON_PERSON_FOLLOWERS_COUNT] intValue];
        self.followeesCount = [json[JSON_PERSON_FOLLOWEES_COUNT] intValue];
        self.streamablesCount = [json[JSON_PERSON_STREAMABLES_COUNT] intValue];
        self.isFollowing = [json[JSON_PERSON_IS_FOLLOWING] intValue] == 1;
    }
    
    return self;
}

- (NSDictionary *)asDictionary {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[JSON_PERSON_ID] = @(self.userId);
    
    if (self.externalId)
        json[JSON_PERSON_EXTERNAL_ID] = self.externalId;
    if (self.username)
        json[JSON_PERSON_USERNAME] = self.username;
    if (self.firstname)
        json[JSON_PERSON_FIRSTNAME] = self.firstname;
    if (self.lastname)
        json[JSON_PERSON_LASTNAME] = self.lastname;
    if (self.email)
        json[JSON_PERSON_EMAIL] = self.email;
    if (self.website)
        json[JSON_PERSON_WEBSITE] = self.website;
    if (self.about)
        json[JSON_PERSON_ABOUT] = self.about;
    
    json[JSON_PERSON_AVATAR_ID] = @(self.avatarId);
    json[JSON_PERSON_COVER_ID] = @(self.coverId);
    
    json[JSON_PERSON_FOLLOWERS_COUNT] = @(self.followersCount);
    json[JSON_PERSON_FOLLOWEES_COUNT] = @(self.followeesCount);
    json[JSON_PERSON_STREAMABLES_COUNT] = @(self.streamablesCount);
    json[JSON_PERSON_IS_FOLLOWING] = @(self.isFollowing);
    
    return json;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

- (NSString *)mentionUsername {
    return [NSString stringWithFormat:@"@%@", self.username];
}

- (NSString *)streamablesCountAsString {
    return [self itemsCountAsString:self.streamablesCount];
}

- (NSString *)followersCountAsString {
    return [self itemsCountAsString:self.followersCount];
}

- (NSString *)followingCountAsString {
    return [self itemsCountAsString:self.followeesCount];
}

- (NSString *)itemsCountAsString:(int)c {
    NSString *s;
    
    if (c < 10000)
        s = [NSString stringWithFormat:@"%i", c];
    else
        s = [NSString stringWithFormat:@"%i K", c / 1000];
    
    return s;
}

- (NSString *)aboutString {
    if (!self.about && !self.website)
        return nil;
    
    NSMutableString *s = [NSMutableString new];
    
    if (self.about) {
        [s appendString:self.about];
        
        if (self.website)
            [s appendString:@"\n\n"];
    }
    
    if (self.website)
        [s appendString:self.website];
    
    return s;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(Person *)aWidget {
    if (self == aWidget)
        return YES;
    if (self.userId != aWidget.userId)
        return NO;
    return YES;
}

@end
