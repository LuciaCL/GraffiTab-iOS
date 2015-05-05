//
//  SearchViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchUsersViewController.h"
#import "SearchGraffitiViewController.h"

@interface SearchViewController () {
    
    IBOutlet UISearchBar *searchBar;
    
    BOOL loaded;
    NSMutableArray *viewControllers;
}

@end

@implementation SearchViewController

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
    
    if (!loaded) {
        [self reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [searchBar becomeFirstResponder];
        });
    }
    
    loaded = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
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
        return @"People";
    else
        return @"Graffiti";
}

- (UIColor *)tabColor {
    return UIColorFromRGB(COLOR_MAIN);
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    [searchBar endEditing:YES];
    
    UIViewController *vc = viewControllers[self.selectedIndex];
    
    if ([vc isKindOfClass:[SearchUsersViewController class]]) {
        SearchUsersViewController *searchVC = (SearchUsersViewController *)vc;
        searchVC.searchString = sb.text;
    }
    else if ([vc isKindOfClass:[SearchGraffitiViewController class]]) {
        SearchGraffitiViewController *searchVC = (SearchGraffitiViewController *)vc;
        searchVC.searchString = sb.text;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb {
    [searchBar endEditing:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - Setup

- (void)setupTopBar {
    self.navigationItem.titleView = searchBar;
}

- (void)setupTabPager {
    [self setDataSource:self];
    [self setDelegate:self];
}

- (void)setupViewControllers {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    
    SearchUsersViewController *vc1 = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchUsersViewController"];
    SearchGraffitiViewController *vc2 = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchGraffitiViewController"];
    
    [viewControllers addObject:vc1];
    [viewControllers addObject:vc2];
}

@end
