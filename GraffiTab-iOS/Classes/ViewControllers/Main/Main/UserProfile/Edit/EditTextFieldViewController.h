//
//  EditTextFieldViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonTableViewController.h"

@interface EditTextFieldViewController : BackButtonTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) void (^finishedEditingBlock)(NSString *);
@property (nonatomic, copy) NSString *defaultValue;
@property (nonatomic, assign) BOOL canBeEmpty;

@end
