//
//  SearchUsersViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SearchUsersViewController.h"

@interface SearchUsersViewController ()

@end

@implementation SearchUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    
    [self refresh];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    if (!self.searchString || self.searchString.length <= 0) {
        [GTUserManager getMostActiveUsersWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
            successBlock(response);
        } cacheBlock:^(GTResponseObject *response) {
            cacheBlock(response);
        } failureBlock:^(GTResponseObject *response) {
            failureBlock(response);
        }];
    }
    else {
        // Perform search.
        [GTSearchManager searchUsersWithQuery:self.searchString offset:o numberOfItems:MAX_ITEMS successBlock:^(GTResponseObject *response) {
            successBlock(response);
        } failureBlock:^(GTResponseObject *response) {
            failureBlock(response);
        }];
    }
}

@end
