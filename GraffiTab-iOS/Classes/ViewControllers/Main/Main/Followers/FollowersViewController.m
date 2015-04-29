//
//  FollowersViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 04/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "FollowersViewController.h"
#import "GetFollowersTask.h"

@interface FollowersViewController ()

@end

@implementation FollowersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    GetFollowersTask *task = [GetFollowersTask new];
    task.isStart = isStart;
    [task getFollowersWithUserId:self.user.userId start:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(ResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(ResponseObject *response) {
        failureBlock(response);
    }];
}

#pragma mark - Initialization

- (void)basicInit {
    self.title = @"Followers";
}

@end
