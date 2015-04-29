//
//  UserHeaderProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_UserHeaderProtocol_h
#define DigiGraff_IOS_UserHeaderProtocol_h

@protocol UserHeaderProtocol <NSObject>

@required
- (void)didTapChangeAvatar;
- (void)didTapChangeCover;
- (void)didTapBack;
- (void)didTapSettings;
- (void)didTapMessage;
- (void)didTapGraffiti;
- (void)didTapFollowers;
- (void)didTapFollowing;
- (void)didTapFollow;

@end

#endif
