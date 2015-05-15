//
//  AboutViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController () {
    
    IBOutlet UITableViewCell *versionCell;
    IBOutlet UITableViewCell *buildCell;
}

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setipTopView];
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)loadData {
    versionCell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    buildCell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            [self showInfoController:[[NSBundle mainBundle] pathForResource:@"release_notes" ofType:@"html"] title:@"Release Notes"];
        else
            [self performSegueWithIdentifier:@"SEGUE_APP_INFO" sender:nil];
    }
}

#pragma mark - Setup

- (void)setipTopView {
    self.title = @"About";
}

@end
