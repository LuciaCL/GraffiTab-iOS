//
//  LikesViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "LikesViewController.h"

@interface LikesViewController ()

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeLoadingIndicator {
    if (self.embedded)
        self.navigationItem.rightBarButtonItems = nil;
    else
        [super removeLoadingIndicator];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    [GTStreamableManager getLikersWithItemId:self.item.streamableId start:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(GTResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(GTResponseObject *response) {
        failureBlock(response);
    }];
}

- (void)showUserProfile:(GTPerson *)user {
    if (self.embedded) {
        [self.parentPopover dismissPopoverAnimated:YES completion:^{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [ViewControllerUtils showUserProfile:user fromViewController:[ViewControllerUtils getVisibleViewController]];
            }];
        }];
    }
    else
        [ViewControllerUtils showUserProfile:user fromViewController:self];
}

#pragma mark - Initialization

- (void)basicInit {
    self.title = @"People who like this";
}

@end
