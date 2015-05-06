//
//  MyNotificationsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MyNotificationsViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "NotificationCellFactory.h"
#import "HomeViewController.h"
#import "TagDetailsViewController.h"
#import "RTSpinKitView.h"

@interface MyNotificationsViewController () {
    
    RTSpinKitView *loadingIndicator;
    
    NSMutableArray *items;
}

@property (nonatomic, weak) IBOutlet UITableView *theTable;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) int offset;

@end

@implementation MyNotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _offset = 0;
    _canLoadMore = YES;
    _isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self loadItems:YES withOffset:_offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    [_theTable ins_removeInfinityScroll];
    [_theTable ins_removePullToRefresh];
}

#pragma mark - Loading

- (void)refresh {
    _offset = 0;
    _canLoadMore = YES;
    
    [self loadItems:NO withOffset:_offset];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    if (items.count <= 0 && !_isDownloading) {
        [loadingIndicator startAnimating];
        _theTable.tableHeaderView = nil;
    }
    
    [self showLoadingIndicator];
    
    _isDownloading = YES;
    
    [GTNotificationManager getNotificationsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        HomeViewController *vc = [SlideNavigationController sharedInstance].viewControllers[0];
        vc.unseenNotificationsCount = 0;
        [vc updateUnseenNotificationsBadge];
        
        if (o == 0)
            [items removeAllObjects];
        
        [items addObjectsFromArray:response.object];
        
        if ([response.object count] <= 0 || [response.object count] < MAX_ITEMS)
            _canLoadMore = NO;
        
        [self finalizeLoad];
    } cacheBlock:^(GTResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(GTResponseObject *response) {
        _canLoadMore = NO;
        
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
    
    [_theTable reloadData];
}

- (void)finalizeLoad {
    [_theTable ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [loadingIndicator stopAnimating];
    
    _isDownloading = NO;
    [_theTable ins_endInfinityScroll];
    [_theTable ins_setInfinityScrollEnabled:_canLoadMore];
    
    [_theTable reloadData];
    
    [self checkNoItemsHeader];
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
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _theTable.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        _theTable.tableHeaderView = l;
    }
    else
        _theTable.tableHeaderView = nil;
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

- (void)setupLoadingIndicator {
    loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:loadingIndicator];
    
    CGPoint c = self.view.center;
    c.y = 60;
    loadingIndicator.center = c;
}

- (void)setupTableView {
    _theTable.tableFooterView = [UIView new];
    
    // Setup pull-to-refresh
    __weak typeof(self) weakSelf = self;
    
    [_theTable ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [weakSelf refresh];
    }];
    
    _theTable.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    [_theTable ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf.canLoadMore && !weakSelf.isDownloading) {
            weakSelf.offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf.offset];
        }
        else {
            weakSelf.isDownloading = NO;
            
            [weakSelf.theTable ins_endInfinityScroll];
            [weakSelf.theTable ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [_theTable.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    _theTable.ins_infiniteScrollBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    _theTable.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [_theTable.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
