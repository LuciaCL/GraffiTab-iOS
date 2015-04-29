//
//  DialogBuilder.h
//  EZtrans
//
//  Created by Georgi Christov on 7/14/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogBuilder : NSObject

+ (void)buildYesNoDialogWithTitle:(NSString *)title message:(NSString *)msg yesTitle:(NSString *)yTitle noTitle:(NSString *)nTitle yesBlock:(void (^)(void))yesHandler noBlock:(void (^)(void))noHandler;

@end
