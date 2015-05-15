//
//  CreditsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CreditsViewController.h"

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTopBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Credits";
}

@end
