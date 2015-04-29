//
//  Settings.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "Settings.h"

@implementation Settings

static Settings *sharedInstance = nil;

+ (Settings *)getInstance {
    if (!sharedInstance)
        sharedInstance = [Settings new];
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)baseInit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:KEY_LOGGED_IN_USER])
        self.user = [[Person alloc] initFromJson:[defaults objectForKey:KEY_LOGGED_IN_USER]];
}

- (BOOL)isLoggedIn {
    return self.user != nil;
}

- (void)setUser:(Person *)p {
    _user = p;
    
    if (p) {
        [[NSUserDefaults standardUserDefaults] setObject:p.asDictionary forKey:KEY_LOGGED_IN_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LOGGED_IN_USER];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)showedTipMenu {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_TIP_MENU];
}

- (void)setShowedTipMenu {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_TIP_MENU];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)token {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KEY_TOKEN];
}

- (void)setToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:KEY_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
