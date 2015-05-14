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
#import "LikesViewController.h"
#import "CommentsViewController.h"
#import "TagDetailsViewController.h"
#import "STThumbnailCollectionCellFactory.h"
#import "STFullSizeCollectionCellFactory.h"
#import "UserProfileViewController.h"
#import "STMediumCollectionCellFactory.h"
#import "FBLikeLayout.h"

@interface STViewController () {
    
    NSMutableArray *items;
    NSMutableSet *shownIndexes;
}

@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) int offset;

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
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _offset = 0;
    _canLoadMore = YES;
    _isDownloading = NO;
    items = [NSMutableArray new];
    shownIndexes = [NSMutableSet set];
    
    [self setupLoadingIndicator];
    [self setupCollectionView];
    
    [self loadItems:YES withOffset:_offset];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self layoutComponents];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if (self.viewType == STVIEW_TYPE_RANDOM) {
        if (![self.collectionView.collectionViewLayout isKindOfClass:[FBLikeLayout class]]) {
            FBLikeLayout *layout = [FBLikeLayout new];
            layout.minimumInteritemSpacing = 4;
            layout.singleCellWidth = (MIN(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)-self.collectionView.contentInset.left-self.collectionView.contentInset.right-8)/3.0;
            layout.maxCellSpace = 3;
            layout.forceCellWidthForMinimumInteritemSpacing = YES;
            layout.fullImagePercentageOfOccurrency = 50;
            self.collectionView.collectionViewLayout = layout;
            
            [self.collectionView reloadData];
        } else {
            //[self.collectionView.collectionViewLayout invalidateLayout];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    [self.collectionView ins_removeInfinityScroll];
    [self.collectionView ins_removePullToRefresh];
}

- (void)setViewType:(STViewType)viewType {
    _viewType = viewType;
    
    [self.collectionView reloadData];
}

- (void)showStreamableTag:(GTStreamableTag *)streamable {
    [ViewControllerUtils showTag:streamable fromViewController:self];
}

- (void)showStreamableVideo:(GTStreamableVideo *)streamable {
    
}

#pragma mark - Loading

- (void)refresh {
    _offset = 0;
    _canLoadMore = YES;
    
    [self loadItems:NO withOffset:_offset];
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o {
    if (items.count <= 0 && !_isDownloading) {
        if (isStart)
            [self.loadingIndicator startAnimating];
        
        [[self.collectionView viewWithTag:1001] removeFromSuperview];
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
    
    [self.collectionView reloadData];
}

- (void)finalizeLoad {
    [self.collectionView ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [self.loadingIndicator stopAnimating];
    
    _isDownloading = NO;
    [self.collectionView ins_endInfinityScroll];
    [self.collectionView ins_setInfinityScrollEnabled:_canLoadMore];
    
    [self.collectionView reloadData];
    
    [self checkNoItemsHeader];
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

- (void)didTapLike:(GTStreamable *)p {
    if (p.isLiked) { // Unlike item.
        [GTStreamableManager unlikeItemWithId:p.streamableId successBlock:^(GTResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.collectionView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.collectionView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    else { // Like item.
        [GTStreamableManager likeItemWithId:p.streamableId successBlock:^(GTResponseObject *response) {
            [items replaceObjectAtIndex:[items indexOfObject:p] withObject:response.object];
            
            [self.collectionView reloadData];
        } failureBlock:^(GTResponseObject *response) {
            [self.collectionView reloadData];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
    
    p.isLiked = !p.isLiked;
    
    [self.collectionView reloadData];
}

- (void)didTapComment:(GTStreamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    CommentsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapShare:(GTStreamable *)item image:(UIImage *)image {
    [ShareUtils shareText:nil andImage:image andUrl:nil viewController:self];
}

- (void)didTapLikesLabel:(GTStreamable *)item {
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    LikesViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    vc.item = item;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didTapOwner:(GTStreamable *)item {
    [ViewControllerUtils showUserProfile:item.user fromViewController:self];
}

#pragma mark - UICollectionViewDelegate

- (CGFloat)getItemSpacing {
    if (self.viewType == STVIEW_TYPE_SMALL)
        return 2.0;
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
    else if (self.viewType == STVIEW_TYPE_RANDOM)
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
    GTStreamable *n = items[indexPath.row];
    
    if ([n isKindOfClass:[GTStreamableTag class]])
        [self showStreamableTag:(GTStreamableTag *) n];
    else if ([n isKindOfClass:[GTStreamableVideo class]]) {
        [self showStreamableVideo:(GTStreamableVideo *) n];
    }
}

- (CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int width;
    int height;
    int numCols = 3;
    CGFloat spacing = [self getItemSpacing];
    GTStreamable *n = items[indexPath.row];
    
    if (self.viewType == STVIEW_TYPE_SMALL) {
        width = (cv.frame.size.width - (numCols + 1)*spacing) / numCols;
        height = width;
    }
    else if (self.viewType == STVIEW_TYPE_MEDIUM) {
        numCols = 2;
        
        width = (cv.frame.size.width - (numCols + 1)*spacing) / numCols;
        height = width + 100;
    }
    else if (self.viewType == STVIEW_TYPE_RANDOM) {
        width = n.width;
        height = n.height;
    }
    else {
        width = self.collectionView.frame.size.width;
        height = width;
        
        if ([n isKindOfClass:[GTStreamableTag class]])
            height = [STTagFullSizeCollectionCell height];
        else if ([n isKindOfClass:[GTStreamableVideo class]])
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

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewType == STVIEW_TYPE_LARGE) {
        if (![shownIndexes containsObject:indexPath]) {
            [shownIndexes addObject:indexPath];
            
            CALayer *layer = cell.layer;
            layer.transform = CATransform3DMakeTranslation(0, self.collectionView.frame.size.height - 50, 0.0f);
            
            [UIView animateWithDuration:indexPath.row == 0 ? 0.0 : 0.8
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                                 cell.layer.transform = CATransform3DIdentity;
                                 
                             } completion:nil];
        }
    }
}

#pragma mark - Layout

- (void)layoutComponents {
    if (![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        self.loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, 60);
        
        CGRect f = self.collectionView.frame;
        f.size.height = self.view.bounds.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT;
        self.collectionView.frame = f;
    }
    else {
        self.loadingIndicator.center = CGPointMake(self.view.frame.size.width/2, 120);
        
        CGRect f = self.collectionView.frame;
        f.size.height = self.view.bounds.size.height;
        self.collectionView.frame = f;
    }
}

#pragma mark - Setup

- (void)setupLoadingIndicator {
    self.loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.loadingIndicator];
}

- (void)setupCollectionView {
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagMediumCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagMediumCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoMediumCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoMediumCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagThumbnailCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagThumbnailCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoThumbnailCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoThumbnailCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STTagFullSizeCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STTagFullSizeCollectionCell reusableIdentifier]];
    [self.collectionView registerNib:[UINib nibWithNibName:[STVideoFullSizeCollectionCell reusableIdentifier] bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:[STVideoFullSizeCollectionCell reusableIdentifier]];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    // Setup pull-to-refresh
    __weak typeof(self) weakSelf = self;
    
    [self.collectionView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [weakSelf refresh];
    }];
    
    self.collectionView.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    [self.collectionView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf.canLoadMore && !weakSelf.isDownloading) {
            weakSelf.offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf.offset];
        }
        else {
            weakSelf.isDownloading = NO;
            
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
