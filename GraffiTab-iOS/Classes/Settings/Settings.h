//
//  Settings.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

+ (Settings *)getInstance;

- (BOOL)showedTipMenu;
- (void)setShowedTipMenu;

@end
