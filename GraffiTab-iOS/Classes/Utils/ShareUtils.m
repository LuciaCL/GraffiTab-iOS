//
//  ShareUtils.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 02/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "ShareUtils.h"

@implementation ShareUtils

+ (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url viewController:(UIViewController *)vc {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text)
        [sharingItems addObject:text];
    if (image)
        [sharingItems addObject:image];
    if (url)
        [sharingItems addObject:url];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [vc presentViewController:activityController animated:YES completion:nil];
}

@end
