//
//  NotificationLike.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Notification.h"

@interface NotificationLike : Notification

@property (nonatomic, strong) Streamable *item;
@property (nonatomic, strong) Person *liker;

@end
