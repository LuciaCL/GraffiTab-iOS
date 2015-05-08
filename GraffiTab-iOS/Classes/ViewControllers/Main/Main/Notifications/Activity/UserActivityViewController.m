//
//  UserActivityViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 08/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "UserActivityViewController.h"

@implementation UserActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        GTResponseObject *response = [GTResponseObject new];
        response.result = SUCCESS;
        response.object = self.items;
        
        successBlock(response);
    });
}

#pragma mark - Initialization

- (void)basicInit {
    self.title = @"People";
}

@end
