//
//  SearchUsersViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SearchUsersViewController.h"
#import "GetMostActiveUsersTask.h"
#import "SearchUsers.h"

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

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    if (!self.searchString || self.searchString.length <= 0) {
        GetMostActiveUsersTask *task = [GetMostActiveUsersTask new];
        task.isStart = isStart;
        [task getMostActiveUsersWithStart:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
            successBlock(response);
        } cacheBlock:^(ResponseObject *response) {
            cacheBlock(response);
        } failureBlock:^(ResponseObject *response) {
            failureBlock(response);
        }];
    }
    else {
        // Perform search.
        SearchUsers *task = [SearchUsers new];
        [task searchUsersWithQuery:self.searchString offset:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
            successBlock(response);
        } failureBlock:^(ResponseObject *response) {
            failureBlock(response);
        }];
    }
}

@end
