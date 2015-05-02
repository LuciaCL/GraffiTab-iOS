//
//  ShareUtils.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 02/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareUtils : NSObject

+ (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url viewController:(UIViewController *)vc;

@end
