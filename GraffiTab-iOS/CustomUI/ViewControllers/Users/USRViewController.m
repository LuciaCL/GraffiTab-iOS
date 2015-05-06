//
//  USRViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "USRViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "UserCell.h"
#import "UserProfileViewController.h"

@interface USRViewController () {
    
    NSMutableArray *items;
}

@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) int offset;

@end

@implementation USRViewController

- (id)init {
    self = [super init];
    
    if (self) {
        [self basicInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self basicInit];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self basicInit];
    }
    
    return self;
}

- (void)basicInit {
    
}

#pragma mark - View lifecycle

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
    
    [self.myTableView ins_removeInfinityScroll];
    [self.myTableView ins_removePullToRefresh];
}

- (void)showUserProfile:(GTPerson *)person {
    [ViewControllerUtils showUserProfile:person fromViewController:self];
}

#pragma mark - Loading

- (void)refresh {
    _offset = 0;
    _canLoadMore = YES;
    
    [self loadItems:NO withOffset:_offset];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o  {
    if (items.count <= 0 && !_isDownloading) {
        [self.loadingIndicator startAnimating];
        self.myTableView.tableHeaderView = nil;
    }
    
    [self showLoadingIndicator];
    
    _isDownloading = YES;
    
    [self loadItems:isStart withOffset:o successBlock:^(GTResponseObject *response) {
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

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    NSLog(@"This should be overridden by subclasses");
}

- (void)finalizeCacheLoad {
    [self.loadingIndicator stopAnimating];
    
    [self.myTableView reloadData];
}

- (void)finalizeLoad {
    [self.myTableView ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [self.loadingIndicator stopAnimating];
    
    _isDownloading = NO;
    [self.myTableView ins_endInfinityScroll];
    [self.myTableView ins_setInfinityScrollEnabled:_canLoadMore];
    
    [self.myTableView reloadData];
    
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
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.myTableView.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        self.myTableView.tableHeaderView = l;
    }
    else
        self.myTableView.tableHeaderView = nil;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserCell reusableIdentifier] forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.item = items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self showUserProfile:items[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UserCell height];
}

#pragma mark - UserCellDelegate

- (void)didTapFollow:(UserCell *)cell {
    GTPerson *p = cell.item;
    
    if (p.isFollowing) { // Unfollow user.
        [GTUserManager unfollowUserWithId:p.userId successBlock:^(GTResponseObject *response) {
            GTPerson *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
        } failureBlock:^(GTResponseObject *response) {
            [self.myTableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Follow user.
        [GTUserManager followUserWithId:p.userId successBlock:^(GTResponseObject *response) {
            GTPerson *responsePerson = response.object;
            
            p.isFollowing = responsePerson.isFollowing;
        } failureBlock:^(GTResponseObject *response) {
            [self.myTableView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isFollowing = !p.isFollowing;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (p.isFollowing) {
            cell.followButton.layer.borderColor = UIColorFromRGB(COLOR_ORANGE).CGColor;
            cell.followButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
            cell.followButton.image = [[UIImage imageNamed:@"ic_action_unfollow.png"] imageWithTint:[UIColor whiteColor]];
        }
        else {
            cell.followButton.layer.borderColor = UIColorFromRGB(COLOR_MAIN).CGColor;
            cell.followButton.backgroundColor = [UIColor whiteColor];
            cell.followButton.image = [[UIImage imageNamed:@"ic_action_follow.png"] imageWithTint:UIColorFromRGB(COLOR_MAIN)];
        }
    } completion:NULL];
}

#pragma mark - Setup

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.loadingIndicator];
    
    CGPoint c = self.view.center;
    c.y = 120;
    self.loadingIndicator.center = c;
}

- (void)setupTableView {
    [self.myTableView registerNib:[UINib nibWithNibName:[UserCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserCell reusableIdentifier]];
    
    self.myTableView.tableFooterView = [UIView new];
    
    // Setup pull-to-refresh
    __weak typeof(self) weakSelf = self;
    
    [self.myTableView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [weakSelf refresh];
    }];
    
    self.myTableView.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    [self.myTableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf.canLoadMore && !weakSelf.isDownloading) {
            weakSelf.offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf.offset];
        }
        else {
            weakSelf.isDownloading = NO;
            
            [weakSelf.myTableView ins_endInfinityScroll];
            [weakSelf.myTableView ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.myTableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    self.myTableView.ins_infiniteScrollBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    self.myTableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.myTableView.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
