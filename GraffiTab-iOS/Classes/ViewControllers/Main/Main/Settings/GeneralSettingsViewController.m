//
//  GeneralSettingsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "GeneralSettingsViewController.h"
#import "InfoViewController.h"

@interface GeneralSettingsViewController ()

@end

@implementation GeneralSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInfoController:(NSString *)file title:(NSString *)title {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    InfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    vc.filePath = file;
    vc.title = title;
    
    [self showController:vc];
}

- (void)showController:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

@end
