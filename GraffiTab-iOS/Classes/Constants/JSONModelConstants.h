//
//  JSONModelConstants.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_JSONModelConstants_h
#define DigiGraff_IOS_JSONModelConstants_h

// Fields for Comment
#define JSON_COMMENT_ID @"id"
#define JSON_COMMENT_ITEMID @"itemId"
#define JSON_COMMENT_USER @"user"
#define JSON_COMMENT_TEXT @"text"
#define JSON_COMMENT_DATE @"date"

// Person.
#define JSON_PERSON_ID @"id"
#define JSON_PERSON_EXTERNAL_ID @"externalId"
#define JSON_PERSON_USERNAME @"username"
#define JSON_PERSON_FIRSTNAME @"firstname"
#define JSON_PERSON_LASTNAME @"lastname"
#define JSON_PERSON_EMAIL @"email"
#define JSON_PERSON_WEBSITE @"website"
#define JSON_PERSON_ABOUT @"about"
#define JSON_PERSON_AVATAR_ID @"avatarId"
#define JSON_PERSON_COVER_ID @"coverId"
#define JSON_PERSON_FOLLOWERS_COUNT @"followersCount"
#define JSON_PERSON_FOLLOWEES_COUNT @"followeesCount"
#define JSON_PERSON_STREAMABLES_COUNT @"streamablesCount"
#define JSON_PERSON_IS_FOLLOWING @"isFollowing"

// Fields for UserLocation
#define JSON_USER_LOCATION_ID @"id"
#define JSON_USER_LOCATION_USER @"user"
#define JSON_USER_LOCATION_ADDRESS @"address"
#define JSON_USER_LOCATION_LATITUDE @"latitude"
#define JSON_USER_LOCATION_LONGITUDE @"longitude"

// Conversation.
#define JSON_CONVERSATION_ID @"id"
#define JSON_CONVERSATION_IMAGE_ID @"imageId"
#define JSON_CONVERSATION_UNSEEN_MESSAGES_COUNT @"unseenMessagesCount"
#define JSON_CONVERSATION_NAME @"name"
#define JSON_CONVERSATION_LAST_MESSAGE @"lastMessage"
#define JSON_CONVERSATION_MEMBERS @"members"

// ConversationMessage.
#define JSON_MESSAGE_ID @"id"
#define JSON_MESSAGE_CONVERSATION_ID @"conversationId"
#define JSON_MESSAGE_USER @"user"
#define JSON_MESSAGE_TEXT @"text"
#define JSON_MESSAGE_DATE @"date"
#define JSON_MESSAGE_SEEN_BY_USERS @"seenByUsers"
#define JSON_MESSAGE_STATE @"state"

// Fields for Notification
#define JSON_NOTIFICATION_ID @"id"
#define JSON_NOTIFICATION_USER @"user"
#define JSON_NOTIFICATION_ISREAD @"isRead"
#define JSON_NOTIFICATION_DATE @"date"
#define JSON_NOTIFICATION_TYPE @"type"

// Fields for NotificationComment
#define JSON_NOTIFICATION_COMMENT_COMMENTER @"commenter"
#define JSON_NOTIFICATION_COMMENT_ITEM @"item"
#define JSON_NOTIFICATION_COMMENT_COMMENT @"comment"

// Fields for NotificationFollow
#define JSON_NOTIFICATION_FOLLOW_FOLLOWER @"follower"

// Fields for NotificationLike
#define JSON_NOTIFICATION_LIKE_ITEM @"item"
#define JSON_NOTIFICATION_LIKE_LIKER @"liker"

// Fields for NotificationMention
#define JSON_NOTIFICATION_MENTION_ITEM @"item"
#define JSON_NOTIFICATION_MENTION_MENTIONER @"mentioner"

// Fields for Streamable
#define JSON_STREAMABLE_ID @"id"
#define JSON_STREAMABLE_USER @"user"
#define JSON_STREAMABLE_DATE @"date"
#define JSON_STREAMABLE_TYPE @"type"
#define JSON_STREAMABLE_ISPRIVATE @"isPrivate"
#define JSON_STREAMABLE_ISFLAGGED @"isFlagged"
#define JSON_STREAMABLE_LIKES_COUNT @"likesCount"
#define JSON_STREAMABLE_COMMENTS_COUNT @"commentsCount"
#define JSON_STREAMABLE_ISLIKED @"isLiked"

// Fields for StreamableTag
#define JSON_STREAMABLE_TAG_GRAFFITIID @"graffitiId"
#define JSON_STREAMABLE_TAG_LATITUDE @"latitude"
#define JSON_STREAMABLE_TAG_LONGITUDE @"longitude"

// Fields for StreamableVideo
#define JSON_STREAMABLE_VIDEO_VIDEOID @"videoId"

#endif
