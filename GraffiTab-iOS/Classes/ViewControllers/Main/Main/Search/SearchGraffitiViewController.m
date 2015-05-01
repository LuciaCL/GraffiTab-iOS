//
//  SearchGraffitiViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SearchGraffitiViewController.h"

@interface SearchGraffitiViewController ()

@end

@implementation SearchGraffitiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    
    [self refresh];
}

- (void)setSearchHashtag:(NSString *)hashtag {
    _searchString = hashtag;
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    if (!self.searchString || self.searchString.length <= 0) {
        [GTStreamableManager getPopularItemsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
            successBlock(response);
        } cacheBlock:^(GTResponseObject *response) {
            cacheBlock(response);
        } failureBlock:^(GTResponseObject *response) {
            failureBlock(response);
        }];
    }
    else {
        // Perform search.
        [GTSearchManager searchHashtagWithQuery:self.searchString offset:o numberOfItems:MAX_ITEMS successBlock:^(GTResponseObject *response) {
            successBlock(response);
        } failureBlock:^(GTResponseObject *response) {
            failureBlock(response);
        }];
    }
}

#pragma mark - Layout

- (void)layoutComponents {
    [super layoutComponents];
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]])
        self.loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, 120);
    else {
        CGRect f = self.collectionView.frame;
        f.size.height = self.view.bounds.size.height;
        self.collectionView.frame = f;
    }
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = [NSString stringWithFormat:@"#%@", self.searchString];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickDone)];
    self.navigationItem.leftBarButtonItem = done;
}

@end
