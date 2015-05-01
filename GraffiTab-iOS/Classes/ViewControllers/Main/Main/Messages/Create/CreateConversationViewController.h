//
//  CreateConversationViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

@interface CreateConversationViewController : BackButtonSLKTextViewController <UITextFieldDelegate>

@property (nonatomic, strong) GTPerson *selectedUser;

@end
