//
//  ConversationSettingsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 13/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonTableViewController.h"

@interface ConversationSettingsViewController : BackButtonTableViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) GTConversation *conversation;

@end
