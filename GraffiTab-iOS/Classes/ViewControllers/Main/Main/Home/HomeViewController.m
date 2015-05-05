//
//  HomeViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "HomeViewController.h"
#import "UIBarButtonItem+Badge.h"
#import "NewestViewController.h"
#import "PopularViewController.h"
#import "HomeStreamViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
    [self setupViewPager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[Settings getInstance] showedTipMenu])
        [[SlideNavigationController sharedInstance] bounceMenu:MenuLeft withCompletion:nil];
    
    [[Settings getInstance] setShowedTipMenu];
    
    [self loadUnseenNotificationCount];
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
}

- (void)onClickToggleMenu {
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

- (void)onClickSpray {
    [self performSegueWithIdentifier:@"SEGUE_DRAW" sender:nil];
}

#pragma mark - Loading notifications

- (void)loadUnseenNotificationCount {
    [GTNotificationManager getUnseenNotificationsWithSuccessBlock:^(GTResponseObject *response) {
        self.unseenNotificationsCount = [response.object intValue];
        
        [GTConversationManager getUnseenConversationsCountWithSuccessBlock:^(GTResponseObject *response) {
            self.unseenMessagesCount = [response.object intValue];
            
            [self updateUnseenNotificationsBadge];
        } failureBlock:^(GTResponseObject *response) {}];
    } failureBlock:^(GTResponseObject *response) {}];
}

- (void)updateUnseenNotificationsBadge {
    int totalNotifications = self.unseenMessagesCount + self.unseenNotificationsCount;
    
    self.navigationItem.leftBarButtonItem.badgeValue = totalNotifications > 0 ? [@(totalNotifications) stringValue] : nil;
    self.navigationItem.leftBarButtonItem.badgeBGColor = UIColorFromRGB(COLOR_ORANGE);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_UNSEEN_ITEMS object:nil];
}

#pragma mark - SlideNavigationControllerDelegate

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Setup

- (void)setupTopBar {
    UIImage *image = [[UIImage imageNamed:@"menu.png"] imageWithTint:self.navigationController.navigationBar.tintColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onClickToggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].leftBarButtonItem = navLeftButton;
    
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"spray.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickSpray)];
    self.navigationItem.rightBarButtonItems = @[create];
}

- (void)setupViewPager {
    NSArray *titles = [NSArray arrayWithObjects:@"Home", @"Popular", @"Newest", nil];
    NSMutableArray *viewControllers = [NSMutableArray new];
    
    for (int i = 0; i < titles.count; i++) {
        UIViewController *vc = nil;
        UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
        
        if (i == 0) {
            HomeStreamViewController *v = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomeStreamViewController"];
            vc = v;
        }
        else if (i == 1) {
            PopularViewController *v = [mainStoryboard instantiateViewControllerWithIdentifier:@"PopularViewController"];
            vc = v;
        }
        else {
            NewestViewController *v = [mainStoryboard instantiateViewControllerWithIdentifier:@"NewestViewController"];
            vc = v;
        }
        
        [viewControllers addObject:vc];
    }
    
    self.viewControllers = viewControllers;
    self.didChangedPageCompleted = ^(NSInteger cuurentPage, NSString *title) {};
    
    [self reloadData];
}

@end
