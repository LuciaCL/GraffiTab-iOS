//
//  RequestBuilder.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/10/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestBuilder : NSObject

+ (NSString *)buildResetPassword;
+ (NSString *)buildSignUp;
+ (NSString *)buildLogin;
+ (NSString *)buildLogout;
+ (NSString *)buildVerify;
+ (NSString *)buildLinkExternalId;
+ (NSString *)buildEditAvatar;
+ (NSString *)buildEditCover;
+ (NSString *)buildEditProfile;
+ (NSString *)buildEditPassword;
+ (NSString *)buildCheckLoginStatus;
+ (NSString *)buildGetAvatar:(long)avatarId;
+ (NSString *)buildGetAvatarForUsername:(NSString *)username;
+ (NSString *)buildGetCover:(long)coverId;
+ (NSString *)buildFindSocialFriends;
+ (NSString *)buildFindUserForUsername;
+ (NSString *)buildFollow;
+ (NSString *)buildUnfollow;
+ (NSString *)buildGetMostActiveUsers;
+ (NSString *)buildGetFollowers;
+ (NSString *)buildGetFollowing;
+ (NSString *)buildGetFullProfile;

+ (NSString *)buildSearchUsers;
+ (NSString *)buildSearchHashtag;
+ (NSString *)buildSearchHashtags;

+ (NSString *)buildRegisterDevice;
+ (NSString *)buildUnregisterDevice;

+ (NSString *)buildGetNotifications;
+ (NSString *)buildGetUnseenNotifications;

+ (NSString *)buildGetGraffiti:(long)graffitiId;
+ (NSString *)buildGetFullGraffiti:(long)graffitiId;
+ (NSString *)buildCreateTag;
+ (NSString *)buildGetUserItems;
+ (NSString *)buildGetFavouriteUserItems;
+ (NSString *)buildGetNewestItems;
+ (NSString *)buildGetItemsForLocation;
+ (NSString *)buildGetUserHomeStreamItems;
+ (NSString *)buildGetPopularItems;
+ (NSString *)buildLikeItem;
+ (NSString *)buildUnlikeItem;
+ (NSString *)buildGetLikers;

+ (NSString *)buildCreateConversation;
+ (NSString *)buildLeaveConversation;
+ (NSString *)buildGetConversations;
+ (NSString *)buildGetMessages;
+ (NSString *)buildPostMessage;
+ (NSString *)buildShowTypingIndicator;
+ (NSString *)buildHideTypingIndicator;
+ (NSString *)buildGetUnseenConversations;
+ (NSString *)buildEditMessage;
+ (NSString *)buildDeleteMessages;
+ (NSString *)buildEditConversationName;
+ (NSString *)buildEditConversationImage;
+ (NSString *)buildAddConversationUsers;
+ (NSString *)buildGetConversationImage:(long)imageId;

+ (NSString *)buildGetUserLocations;
+ (NSString *)buildCreateUserLocation;
+ (NSString *)buildDeleteUserLocations;

+ (NSString *)buildPostComment;
+ (NSString *)buildEditComment;
+ (NSString *)buildGetComments;
+ (NSString *)buildDeleteComments;

+ (NSString *)buildPostFeedback;

@end
