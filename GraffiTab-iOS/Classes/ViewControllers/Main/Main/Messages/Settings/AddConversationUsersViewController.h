//
//  AddConversationUsersViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "TITokenField.h"

@interface AddConversationUsersViewController : BackButtonViewController <TITokenFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) Conversation *conversation;

@end
