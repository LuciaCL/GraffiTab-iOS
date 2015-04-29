//
//  STViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "GetNotificationsTask.h"
#import "GetPopularItemsTask.h"
#import "LikeItemTask.h"
#import "UnlikeItemTask.h"
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "TagDetailsViewController.h"
#import "STThumbnailCollectionCellFactory.h"
#import "STFullSizeCollectionCellFactory.h"
#import "UserProfileViewController.h"
#import "TagDetailsTransitioningDelegate.h"
#import "TagDetailsBounceTransitioningDelegate.h"
#import "STMediumCollectionCellFactory.h"

@interface STViewController () {
    
    TagDetailsTransitioningDelegate *transitioningDelegate;
    TagDetailsBounceTransitioningDelegate *transitioningBounceDelegate;
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
}

@end

@implementation STViewController

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
    _viewType = STVIEW_TYPE_MEDIUM;
    
    transitioningDelegate = [TagDetailsTransitioningDelegate new];
    transitioningBounceDelegate = [TagDetailsBounceTransitioningDelegate new];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    offset = 0;
    canLoadMore = YES;
    isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupLoadingIndicator];
    [self setupCollectionView];
    
    [self loadItems:YES withOffset:offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.collectionView ins_removeInfinityScroll];
    [self.collectionView ins_removePullToRefresh];
}

- (void)setViewType:(STViewType)viewType {
    _viewType = viewType;
    
    [self.collectionView reloadData];
}

#pragma mark - Loading

- (void)refresh {
    offset = 0;
    canLoadMore = YES;
    
    [self loadItems:NO withOffset:offset];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    if (items.count <= 0 && !isDownloading) {
        [self.loadingIndicator startAnimating];
        [[self.collectionView viewWithTag:1001] removeFromSuperview];
    }
    
    [self showLoadingIndicator];
    
    isDownloading = YES;
    
    [self loadItems:isStart withOffset:o successBlock:^(ResponseObject *response) {
        if (o == 0)
            [items removeAllObjects];
        
        [items addObjectsFromArray:response.object];
        
        if ([response.object count] <= 0 || [response.object count] < MAX_ITEMS)
            canLoadMore = NO;
        
        [self finalizeLoad];
    } cacheBlock:^(ResponseObject *response) {
        [items removeAllObjects];
        [items addObjectsFromArray:response.object];
        
        [self finalizeCacheLoad];
    } failureBlock:^(ResponseObject *response) {
        canLoadMore = NO;
        
        [self finalizeLoad];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    NSLog(@"This should be overridden by subclasses");
}

- (void)finalizeCacheLoad {
    [self.loadingIndicator stopAnimating];
    
    [self.collectionView reloadData];
}

- (void)finalizeLoad {
    [self.collectionView ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [self.loadingIndicator stopAnimating];
    
    isDownloading = NO;
    [self.collectionView ins_endInfinityScroll];
    [self.collectionView ins_setInfinityScrollEnabled:canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        
        [self checkNoItemsHeader];
    });
}

- (void)showLoadingIndicator {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:indicator]] animated:YES];
}

- (void)removeLoadingIndicator {
    UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    [self.navigationItem setRightBarButtonItems:@[reload] animated:YES];
}

- (void)checkNoItemsHeader {
    if (items.count <= 0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        l.tag = 1001;
        [self.collectionView addSubview:l];
    }
    else
        [[self.collectionView viewWithTag:1001] removeFromSuperview];
}

#pragma mark - StreamableTableCellDelegate

- (void)didTapLike:(Streamable *)p {
    if (p.isLiked) { // Unlike item.
        UnlikeItemTask *task = [UnlikeItemTask new];
        [task unlikeItemWithId:p.streamableId successBlock:^(ResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.collectionView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.collectionView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Like item.
        LikeItemTask *task = [LikeItemTask new];
        [task likeItemWithId:p.streamableId successBlock:^(ResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.collectionView reloadData];
        } failureBlock:^(ResponseObject *response) {
            [self.collectionView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isLiked = !p.isLiked;
    
    [self.collectionView reloadData];
}

- (void)didTapComment:(Streamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    CommentsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapLikesLabel:(Streamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    LikesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapOwner:(Streamable *)item {
    [ViewControllerUtils showUserProfile:item.user fromViewController:self];
}

#pragma mark - UICollectionViewDelegate

- (CGFloat)getItemSpacing {
    if (self.viewType == STVIEW_TYPE_SMALL)
        return 5.0;
    else if (self.viewType == STVIEW_TYPE_MEDIUM)
        return 10.0;
    else
        return 0;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return items.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewType == STVIEW_TYPE_SMALL)
        return [STThumbnailCollectionCellFactory createStreamableCollectionCellForStreamable:items[indexPath.row] tableView:cv indexPath:indexPath];
    else if (self.viewType == STVIEW_TYPE_MEDIUM) {
        STMediumCollectionCell *cell = [STMediumCollectionCellFactory createStreamableCollectionCellForStreamable:items[indexPath.row] tableView:cv indexPath:indexPath];
        cell.delegate = self;
        
        return cell;
    }
    else {
        STFullSizeCollectionCell *cell = [STFullSizeCollectionCellFactory createStreamableCollectionCellForStreamable:items[indexPath.row] tableView:cv indexPath:indexPath];
        cell.delegate = self;
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Streamable *n = items[indexPath.row];
    
    if ([n isKindOfClass:[StreamableTag class]]) {
        if (self.viewType == STVIEW_TYPE_SMALL || self.viewType == STVIEW_TYPE_MEDIUM) {
            UICollectionViewLayoutAttributes *attributes = [cv layoutAttributesForItemAtIndexPath:indexPath];
            CGRect cellRect = attributes.frame;
            CGRect cellFrameInSuperview = [cv convertRect:cellRect toView:nil];
            
            [ViewControllerUtils showTag:(StreamableTag *) n fromViewController:self originFrame:cellFrameInSuperview transitionDelegate:transitioningDelegate];
        }
        else
            [ViewControllerUtils showTag:(StreamableTag *) n fromViewController:self originFrame:CGRectNull transitionDelegate:transitioningBounceDelegate];
    }
    else if ([n isKindOfClass:[StreamableVideo class]]) {
        
    }
}

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width;
    int height;
    int numCols = 3;
    CGFloat spacing = [self getItemSpacing];
    Streamable *n = items[indexPath.row];
    
    if (self.viewType == STVIEW_TYPE_SMALL) {
        width = (cv.frame.size.width - (numCols + 1)*spacing) / numCols;
        height = width;
    }
    else if (self.viewType == STVIEW_TYPE_MEDIUM) {
        numCols = 2;
        
        width = (cv.frame.size.width - (numCols + 1)*spacing) / numCols;
        height = width + 100;
    }
    else {
        width = self.collectionView.frame.size.width;
        height = width;
        
        if ([n isKindOfClass:[StreamableTag class]])
            height = [STTagFullSizeCollectionCell height];
        else if ([n isKindOfClass:[StreamableVideo class]])
            height = [STVideoFullSizeCollectionCell height];
    }
    
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self getItemSpacing];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return [self getItemSpacing];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat spacing = [self getItemSpacing];
    
    if (self.viewType == STVIEW_TYPE_SMALL || self.viewType == STVIEW_TYPE_MEDIUM)
        return UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    else
        return UIEdgeInsetsZero;
}

#pragma mark - Setup

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.loadingIndicator];

    CGPoint c = self.view.center;
    c.y = self.embedded ? 60 : 120;
    self.loadingIndicator.center = c;
}

- (void)setupCollectionView {
    if (self.embedded) {
        CGRect f = self.collectionView.frame;
        f.size.height = self.view.bounds.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT;
        self.collectionView.frame = f;
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagMediumCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagMediumCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoMediumCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoMediumCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagThumbnailCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagThumbnailCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoThumbnailCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoThumbnailCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagFullSizeCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagFullSizeCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoFullSizeCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoFullSizeCollectionCell reusableIdentifier]];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    // Setup pull-to-refresh
    [self.collectionView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [self refresh];
    }];
    
    self.collectionView.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    __strong typeof(self) weakSelf = self;
    
    [self.collectionView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf->canLoadMore && !weakSelf->isDownloading) {
            weakSelf->offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf->offset];
        }
        else {
            weakSelf->isDownloading = NO;
            
            [weakSelf.collectionView ins_endInfinityScroll];
            [weakSelf.collectionView ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.collectionView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    self.collectionView.ins_infiniteScrollBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.collectionView.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
