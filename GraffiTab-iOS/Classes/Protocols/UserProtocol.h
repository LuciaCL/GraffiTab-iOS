//
//  UserProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef DigiGraff_IOS_UserProtocol_h
#define DigiGraff_IOS_UserProtocol_h

@class UserCell;

@protocol UserProtocol <NSObject>

@required
- (void)didTapFollow:(UserCell *)cell;

@end

#endif
