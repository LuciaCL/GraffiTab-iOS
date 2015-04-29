//
//  DialogBuilder.m
//  EZtrans
//
//  Created by Georgi Christov on 7/14/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import "DialogBuilder.h"
#import "UIAlertView+Blocks.h"

@implementation DialogBuilder

+ (void)buildYesNoDialogWithTitle:(NSString *)title message:(NSString *)msg yesTitle:(NSString *)yTitle noTitle:(NSString *)nTitle yesBlock:(void (^)(void))yesHandler noBlock:(void (^)(void))noHandler {
    [[[UIAlertView alloc] initWithTitle:title
                                message:msg
                       cancelButtonItem:[RIButtonItem itemWithLabel:nTitle action:^{
                                            // Handle "Cancel"
                                            noHandler();
                                        }]
                       otherButtonItems:[RIButtonItem itemWithLabel:yTitle action:^{
                                            // Handle "Delete"
                                            yesHandler();
                                        }], nil] show];
}

@end
