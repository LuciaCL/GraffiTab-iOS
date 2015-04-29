//
//  STMediumOnlyViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 22/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STMediumOnlyViewController.h"

@interface STMediumOnlyViewController ()

@end

@implementation STMediumOnlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization

- (void)basicInit {
    [super basicInit];
    
    self.viewType = STVIEW_TYPE_MEDIUM;
}

@end
