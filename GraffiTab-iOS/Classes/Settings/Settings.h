//
//  Settings.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Settings : NSObject

@property (nonatomic, strong) Person *user;

+ (Settings *)getInstance;

- (BOOL)isLoggedIn;

- (BOOL)showedTipMenu;
- (void)setShowedTipMenu;

- (NSString *)token;
- (void)setToken:(NSString *)token;

@end
