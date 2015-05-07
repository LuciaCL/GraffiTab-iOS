//
//  NotificationsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 06/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "NotificationsViewController.h"
#import "MyNotificationsViewController.h"
#import "FollowingNotificationsViewController.h"

@interface NotificationsViewController () {
    
    BOOL loaded;
    NSMutableArray *viewControllers;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    viewControllers = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupTabPager];
    [self setupViewControllers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!loaded)
        [self reloadData];
    
    loaded = YES;
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

- (void)onClickClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Tab Pager Data Source

- (NSInteger)numberOfViewControllers {
    return viewControllers.count;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
    return viewControllers[index];
}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
    if (index == 0)
        return @"You";
    else
        return @"Following";
}

- (UIColor *)tabColor {
    return UIColorFromRGB(COLOR_MAIN);
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Activity";
    
    if (self.isModal)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickClose)];
}

- (void)setupTabPager {
    [self setDataSource:self];
    [self setDelegate:self];
}

- (void)setupViewControllers {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    
    MyNotificationsViewController *vc1 = [mainStoryboard instantiateViewControllerWithIdentifier:@"MyNotificationsViewController"];
    FollowingNotificationsViewController *vc2 = [mainStoryboard instantiateViewControllerWithIdentifier:@"FollowingNotificationsViewController"];
    
    [viewControllers addObject:vc1];
    [viewControllers addObject:vc2];
}

@end
