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
    
}

- (BOOL)showedTipMenu {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_TIP_MENU];
}

- (void)setShowedTipMenu {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_TIP_MENU];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
