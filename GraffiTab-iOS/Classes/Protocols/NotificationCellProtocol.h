//
//  NotificationCellProtocol.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 07/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#ifndef GraffiTab_iOS_NotificationCellProtocol_h
#define GraffiTab_iOS_NotificationCellProtocol_h

@protocol NotificationCellProtocol <NSObject>

@required
- (void)didTapAvatar:(GTPerson *)person;

@end

#endif
