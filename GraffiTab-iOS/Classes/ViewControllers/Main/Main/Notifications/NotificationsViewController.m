//
//  NotificationsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "NotificationsViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "NotificationCellFactory.h"
#import "HomeViewController.h"
#import "TagDetailsViewController.h"
#import "RTSpinKitView.h"

@interface NotificationsViewController () {
    
    IBOutlet UITableView *theTable;
    
    RTSpinKitView *loadingIndicator;
    
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    offset = 0;
    canLoadMore = YES;
    isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self loadItems:YES withOffset:offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [theTable ins_removeInfinityScroll];
    [theTable ins_removePullToRefresh];
}

- (void)onClickClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Loading

- (void)refresh {
    offset = 0;
    canLoadMore = YES;
    
    [self loadItems:NO withOffset:offset];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    if (items.count <= 0 && !isDownloading) {
        [loadingIndicator startAnimating];
        theTable.tableHeaderView = nil;
    }
    
    [self showLoadingIndicator];
    
    isDownloading = YES;
    
    [GTNotificationManager getNotificationsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        HomeViewController *vc = [SlideNavigationController sharedInstance].viewControllers[0];
        vc.unseenNotificationsCount = 0;
        [vc updateUnseenNotificationsBadge];
        
        if (o == 0)
            [items removeAllObjects];
        
        [items addObjectsFromArray:response.object];
        
        if ([response.object count] <= 0 || [response.object count] < MAX_ITEMS)
            canLoadMore = NO;
        
        [self finalizeLoad];
    } cacheBlock:^(GTResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(GTResponseObject *response) {
        canLoadMore = NO;
        
        [self finalizeLoad];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)finalizeCacheLoad {
    [loadingIndicator stopAnimating];
    
    [theTable reloadData];
}

- (void)finalizeLoad {
    [theTable ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [loadingIndicator stopAnimating];
    
    isDownloading = NO;
    [theTable ins_endInfinityScroll];
    [theTable ins_setInfinityScrollEnabled:canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [theTable reloadData];
        
        [self checkNoItemsHeader];
    });
}

- (void)showLoadingIndicator {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:indicator] animated:YES];
}

- (void)removeLoadingIndicator {
    UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    [self.navigationItem setRightBarButtonItem:reload animated:YES];
}

- (void)checkNoItemsHeader {
    if (items.count <= 0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, theTable.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        theTable.tableHeaderView = l;
    }
    else
        theTable.tableHeaderView = nil;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NotificationCellFactory createNotificationCellForNotification:items[indexPath.row] tableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GTNotification *n = items[indexPath.row];
    
    UIViewController *controllerToShow;
    BOOL presentModal = NO;
    
    if ([n isKindOfClass:[GTNotificationComment class]]) {
        GTNotificationComment *not = (GTNotificationComment *) n;
        
        if ([not.item isKindOfClass:[GTStreamableTag class]]) {
            [ViewControllerUtils showTag:(GTStreamableTag *) not.item fromViewController:self];
            
            return;
        }
    }
    else if ([n isKindOfClass:[GTNotificationFollow class]]) {
        GTNotificationFollow *not = (GTNotificationFollow *) n;
        
        [ViewControllerUtils showUserProfile:not.follower fromViewController:self];
        
        return;
    }
    else if ([n isKindOfClass:[GTNotificationLike class]]) {
        GTNotificationLike *not = (GTNotificationLike *) n;
        
        if ([not.item isKindOfClass:[GTStreamableTag class]]) {
            [ViewControllerUtils showTag:(GTStreamableTag *) not.item fromViewController:self];
            
            return;
        }
    }
    else if ([n isKindOfClass:[GTNotificationMention class]]) {
        GTNotificationMention *not = (GTNotificationMention *) n;
        
        if ([not.item isKindOfClass:[GTStreamableTag class]]) {
            [ViewControllerUtils showTag:(GTStreamableTag *) not.item fromViewController:self];
            
            return;
        }
    }
    else if ([n isKindOfClass:[GTNotificationWelcome class]]) {
        
    }
    
    if (controllerToShow) {
        if (presentModal)
            [self presentViewController:controllerToShow animated:YES completion:nil];
        else
            [self.navigationController pushViewController:controllerToShow animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GTNotification *n = items[indexPath.row];
    
    if ([n isKindOfClass:[GTNotificationComment class]])
        return [NotificationCommentCell height];
    else if ([n isKindOfClass:[GTNotificationFollow class]])
        return [NotificationFollowCell height];
    else if ([n isKindOfClass:[GTNotificationLike class]])
        return [NotificationLikeCell height];
    else if ([n isKindOfClass:[GTNotificationMention class]])
        return [NotificationMentionCell height];
    else if ([n isKindOfClass:[GTNotificationWelcome class]])
        return [NotificationWelcomeCell height];
    else
        return [NotificationCell height];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    GTNotification *n = items[indexPath.row];
    
    cell.backgroundColor = n.isRead ? [UIColor whiteColor] : [UIColor colorWithHexString:@"#F5EC89" alpha:0.3];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Notifications";
    
    if (self.isModal)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickClose)];
}

- (void)setupLoadingIndicator {
    loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:loadingIndicator];
    
    CGPoint c = self.view.center;
    c.y = 120;
    loadingIndicator.center = c;
}

- (void)setupTableView {
    theTable.tableFooterView = [UIView new];
    
    // Setup pull-to-refresh
    [theTable ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [self refresh];
    }];
    
    theTable.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    __strong typeof(self) weakSelf = self;
    
    [theTable ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf->canLoadMore && !weakSelf->isDownloading) {
            weakSelf->offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf->offset];
        }
        else {
            weakSelf->isDownloading = NO;
            
            [weakSelf->theTable ins_endInfinityScroll];
            [weakSelf->theTable ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [theTable.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    theTable.ins_infiniteScrollBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    theTable.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [theTable.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
