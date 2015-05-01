//
//  TweetProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 29/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_TweetProtocol_h
#define DigiGraff_IOS_TweetProtocol_h

@protocol TweetProtocol <NSObject>

@required
- (void)didClickAvatar:(GTPerson *)user;
- (void)didClickUsername:(NSString *)username;
- (void)didClickHashtag:(NSString *)hashtag;
- (void)didClickLink:(NSString *)link;

@end

#endif
