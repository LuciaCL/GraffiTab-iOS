//
//  MapThumbnailsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 20/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "MapThumbnailsViewController.h"
#import "MZFormSheetController.h"
#import "GetStreamablesForLocationTask.h"

@interface MapThumbnailsViewController ()

- (IBAction)onClickDone:(id)sender;

@end

@implementation MapThumbnailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickDone:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    GetStreamablesForLocationTask *task = [GetStreamablesForLocationTask new];
    task.isStart = isStart;
    [task getForLocationWithNECoordinate:self.neCoord SWCoordinate:self.swCoord start:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(ResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(ResponseObject *response) {
        failureBlock(response);
    }];
}

@end
