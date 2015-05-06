//
//  LocationsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "LocationsViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "UserLocationCell.h"
#import "UIActionSheet+Blocks.h"
#import "RTSpinKitView.h"

@interface LocationsViewController () {
    
    RTSpinKitView *loadingIndicator;
    
    NSMutableArray *items;
}

@property (nonatomic, weak) IBOutlet UITableView *theTable;
@property (nonatomic, assign) BOOL isDownloading;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromNotification) name:NOTIFICATION_UPDATE_LOCATIONS object:nil];
    
    _isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self loadItems:YES];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_theTable ins_removeInfinityScroll];
    [_theTable ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickCreate {
    [self performSegueWithIdentifier:@"SEGUE_CREATE_LOCATION" sender:nil];
}

- (void)onClickEdit {
    if (_theTable.isEditing)
        [_theTable setEditing:NO animated:YES];
    else
        [_theTable setEditing:YES animated:YES];
}

#pragma mark - Loading

- (void)refreshFromNotification {
   [self loadItems:YES];
}

- (void)refresh {
   [self loadItems:NO];
}

- (void)loadItems:(BOOL)isStart {
    if (items.count <= 0 && !_isDownloading) {
        [loadingIndicator startAnimating];
        _theTable.tableHeaderView = nil;
    }
    
    _isDownloading = YES;
    
    [self showLoadingIndicator];
    
    [GTLocationManager getLocationsWithCache:isStart successBlock:^(GTResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeLoad];
    } cacheBlock:^(GTResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(GTResponseObject *response) {
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
    
    [_theTable reloadData];
    
    [self checkNoItemsHeader];
}

- (void)showLoadingIndicator {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:indicator]] animated:YES];
}

- (void)removeLoadingIndicator {
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onClickCreate)];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onClickEdit)];
    
    [self.navigationItem setRightBarButtonItems:@[create, edit] animated:YES];
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
    UserLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserLocationCell" forIndexPath:indexPath];
    
    cell.item = items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GTUserLocation *l = items[indexPath.row];
    
    [ViewControllerUtils showMapLocation:[[CLLocation alloc] initWithLatitude:l.latitude longitude:l.longitude] fromViewController:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTUserLocation *c = [items objectAtIndex:indexPath.row];
        
        NSMutableArray *idsToDelete = [NSMutableArray arrayWithObject:@(c.locationId)];
        
        [GTLocationManager deleteLocations:idsToDelete successBlock:^(GTResponseObject *response) {
            [self checkNoItemsHeader];
        } failureBlock:^(GTResponseObject *response) {
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
        
        // Delete item instantly.
        [items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (items.count <= 0)
            [tableView setEditing:NO animated:YES];
    }
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"My Places";
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
    _theTable.tableFooterView = [UIView new];
    
    // Setup pull-to-refresh
    __weak typeof(self) weakSelf = self;
    
    [_theTable ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [weakSelf refresh];
    }];
    
    _theTable.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    _theTable.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [_theTable.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
