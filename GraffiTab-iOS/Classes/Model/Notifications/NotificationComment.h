//
//  NotificationComment.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Notification.h"

@interface NotificationComment : Notification

@property (nonatomic, strong) Person *commenter;
@property (nonatomic, strong) Streamable *item;
@property (nonatomic, strong) Comment *comment;

@end
