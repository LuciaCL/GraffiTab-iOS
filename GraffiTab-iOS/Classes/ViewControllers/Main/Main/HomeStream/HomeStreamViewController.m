//
//  HomeStreamViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 06/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "HomeStreamViewController.h"
#import "GetUserHomeStreamTask.h"

@interface HomeStreamViewController ()

@end

@implementation HomeStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    GetUserHomeStreamTask *task = [GetUserHomeStreamTask new];
    task.isStart = isStart;
    [task getUserHomeStreamWithStart:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(ResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(ResponseObject *response) {
        failureBlock(response);
    }];
}

#pragma mark - Initialization

- (void)basicInit {
    [super basicInit];
    
    self.title = @"Home";
}

@end
