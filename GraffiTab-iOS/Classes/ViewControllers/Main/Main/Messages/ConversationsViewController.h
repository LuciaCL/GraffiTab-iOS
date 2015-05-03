//
//  ConversationsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationsViewController : BackButtonViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL isModal;

- (void)processMessageNotification:(NSDictionary *)userInfo;

@end
