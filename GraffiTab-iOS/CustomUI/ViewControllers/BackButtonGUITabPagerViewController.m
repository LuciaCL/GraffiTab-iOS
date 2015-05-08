//
//  BackButtonGUITabPagerViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 06/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonGUITabPagerViewController.h"

@interface BackButtonGUITabPagerViewController ()

@end

@implementation BackButtonGUITabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupBackButton {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:(IS_IPAD ? self.title : @"  ") style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end