//
//  STToggleViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STToggleViewController.h"

@interface STToggleViewController ()

@end

@implementation STToggleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickToggle {
    if (self.viewType == STVIEW_TYPE_SMALL)
        self.viewType = STVIEW_TYPE_LARGE;
    else
        self.viewType = STVIEW_TYPE_SMALL;
}

- (void)removeLoadingIndicator {
    UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    UIBarButtonItem *toggle = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"view_toggle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickToggle)];
    
    [self.navigationItem setRightBarButtonItems:@[reload, toggle] animated:YES];
}

@end
