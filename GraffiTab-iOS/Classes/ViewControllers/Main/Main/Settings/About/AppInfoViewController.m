//
//  AppInfoViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController () {
    
    IBOutlet UIImageView *backButton;
    IBOutlet UIImageView *logo;
}

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self animateViews];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)animateViews {
    [UIView animateWithDuration:0.5 animations:^{
        logo.alpha = 1.0;
    }];
}

@end
