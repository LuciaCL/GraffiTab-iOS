//
//  APIConstants.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/10/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#ifndef TheBestOfBulgaria_iOS_APIConstants_h
#define TheBestOfBulgaria_iOS_APIConstants_h

#define API_APP_URL @"http://localhost:8080/TriaServerTomcat"
//#define API_APP_URL @"http://172.18.34.26:8080/TriaServerTomcat"
//#define API_APP_URL @"http://graffitab.com"
#define API_APP_API_URL @"api/rest"

#define API_USER_REGISTER                         @"/user/register"
#define API_USER_LOGIN                            @"/user/login"
#define API_USER_LOGOUT                           @"/user/logout"
#define API_USER_EDIT_PASSWORD                    @"/user/editPassword"
#define API_USER_EDIT_PROFILE                     @"/user/editProfile"
#define API_USER_RESET_PASSWORD                   @"/user/resetPassword"
#define API_USER_EDIT_AVATAR                      @"/user/editAvatar"
#define API_USER_EDIT_COVER                       @"/user/editCover"
#define API_USER_GET_COVER_IMAGE                  @"/user/getCoverImage"
#define API_USER_GET_AVATAR_IMAGE                 @"/user/getAvatarImage"
#define API_USER_GET_AVATAR_IMAGE_FOR_USERNAME    @"/user/getAvatarImageForUsername"
#define API_USER_FOLLOW                           @"/user/follow"
#define API_USER_UNFOLLOW                         @"/user/unfollow"
#define API_USER_GET_FOLLOWERS                    @"/user/getFollowers"
#define API_USER_GET_FOLLOWING                    @"/user/getFollowing"
#define API_USER_GET_MOST_ACTIVE                  @"/user/getMostActive"
#define API_USER_FIND_SOCIAL_NETWORK_FRIENDS      @"/user/findSocialNetworkFriends"
#define API_USER_FIND_FOR_USERNAME                @"/user/findUserForUsername"
#define API_USER_FULL_PROFILE                     @"/user/fullProfile"
#define API_USER_VERIFY_EXTERNAL_USER             @"/user/verifyExternalUser"
#define API_USER_CHECK_LOGIN_STATUS               @"/user/checkLoginStatus"
#define API_USER_LINK_EXTERNAL_ID                 @"/user/linkExternalId"

#define API_SEARCH_USER                           @"/search/user"
#define API_SEARCH_HASHTAG                        @"/search/hashtag"
#define API_SEARCH_HASHTAGS                       @"/search/hashtags"

#define API_LOCATION_CREATE                       @"/location/create"
#define API_LOCATION_DELETE                       @"/location/delete"
#define API_LOCATION_GET                          @"/location/get"

#define API_DEVICE_REGISTER                       @"/device/register"
#define API_DEVICE_UNREGISTER                     @"/device/unregister"

#define API_FEEDBACK_SEND                         @"/feedback/send"

#define API_STREAMABLE_DELETE                     @"/streamable/delete"
#define API_STREAMABLE_LATEST                     @"/streamable/latest"
#define API_STREAMABLE_USER_STREAM                @"/streamable/userStream"
#define API_STREAMABLE_USER_FAVOURITES            @"/streamable/userFavourites"
#define API_STREAMABLE_POPULAR                    @"/streamable/popular"
#define API_STREAMABLE_HOME_STREAM                @"/streamable/homeStream"
#define API_STREAMABLE_FULL_INFO                  @"/streamable/fullInfo"
#define API_STREAMABLE_MAKE_PRIVATE               @"/streamable/makePrivate"
#define API_STREAMABLE_MAKE_PUBLIC                @"/streamable/makePublic"
#define API_STREAMABLE_FLAG                       @"/streamable/flag"
#define API_STREAMABLE_GET_PRIVATE                @"/streamable/getPrivate"

#define API_STREAMABLE_LIKES_LIKE                 @"/streamable/likes/like"
#define API_STREAMABLE_LIKES_UNLIKE               @"/streamable/likes/unlike"
#define API_STREAMABLE_LIKES_GET                  @"/streamable/likes/get"

#define API_STREAMABLE_COMMENTS_POST              @"/streamable/comments/post"
#define API_STREAMABLE_COMMENTS_GET               @"/streamable/comments/get"
#define API_STREAMABLE_COMMENTS_EDIT              @"/streamable/comments/edit"
#define API_STREAMABLE_COMMENTS_DELETE            @"/streamable/comments/delete"

#define API_STREAMABLE_TAG_CREATE                 @"/streamable/tag/create"
#define API_STREAMABLE_TAG_EDIT                   @"/streamable/tag/edit"
#define API_STREAMABLE_TAG_GET_IMAGE              @"/streamable/tag/getImage"
#define API_STREAMABLE_TAG_GET_THUMBNAIL          @"/streamable/tag/getThumbnail"
#define API_STREAMABLE_TAG_GET_FOR_LOCATION       @"/streamable/tag/getForLocation"
#define API_STREAMABLE_TAG_GET_FOR_USER           @"/streamable/tag/getForUser"

#define API_STREAMABLE_VIDEO_CREATE               @"/streamable/video/create"

#define API_CONVERSATION_CREATE                   @"/conversation/create"
#define API_CONVERSATION_LEAVE                    @"/conversation/leave"
#define API_CONVERSATION_GET                      @"/conversation/get"
#define API_CONVERSATION_GET_MESSAGES             @"/conversation/getMessages"
#define API_CONVERSATION_POST_MESSAGE             @"/conversation/postMessage"
#define API_CONVERSATION_SHOW_TYPING_INDICATOR    @"/conversation/showTypingIndicator"
#define API_CONVERSATION_HIDE_TYPING_INDICATOR    @"/conversation/hideTypingIndicator"
#define API_CONVERSATION_GET_UNSEEN_COUNT         @"/conversation/getUnseenCount"
#define API_CONVERSATION_EDIT_NAME                @"/conversation/editName"
#define API_CONVERSATION_EDIT_IMAGE               @"/conversation/editImage"
#define API_CONVERSATION_ADD_USERS                @"/conversation/addUsers"
#define API_CONVERSATION_GET_IMAGE                @"/conversation/getImage"

#define API_MESSAGE_EDIT                          @"/message/edit"
#define API_MESSAGE_DELETE                        @"/message/delete"

#define API_NOTIFICATION_GET_NOTIFICATIONS        @"/notification/getNotifications"
#define API_NOTIFICATION_GET_UNSEEN_COUNT         @"/notification/getUnseenCount"

typedef enum {
    SUCCESS,
    ERROR
} Result;

typedef enum {
    ALREADY_EXISTS,
    DATABASE_ERROR,
    INCORRECT_CREDENTIALS,
    AUTHORIZATION_NEEDED,
    NOT_FOUND,
    NETWORK,
    OTHER
} Reason;

#define RESULT_LIST @[@"SUCCESS", @"ERROR"]
#define REASON_LIST @[@"ALREADY_EXISTS", @"DATABASE_ERROR", @"INCORRECT_CREDENTIALS", @"AUTHORIZATION_NEEDED", @"NOT_FOUND", @"OTHER"]

#define Result(str) (Result)[RESULT_LIST indexOfObject:str]
#define Reason(str) (Reason)[REASON_LIST indexOfObject:str]

#endif
