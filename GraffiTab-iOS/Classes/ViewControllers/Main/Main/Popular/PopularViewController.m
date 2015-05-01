//
//  PopularViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "PopularViewController.h"

@interface PopularViewController ()

@end

@implementation PopularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    [GTStreamableManager getPopularItemsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(GTResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(GTResponseObject *response) {
        failureBlock(response);
    }];
}

#pragma mark - Initialization

- (void)basicInit {
    [super basicInit];
    
    self.title = @"Popular";
}

@end
