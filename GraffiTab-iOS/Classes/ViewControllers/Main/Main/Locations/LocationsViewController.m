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
    
    IBOutlet UIBarButtonItem *editButton;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *deleteButton;
    IBOutlet UIBarButtonItem *createButton;
    
    RTSpinKitView *loadingIndicator;
    
    NSMutableArray *items;
}

@property (nonatomic, weak) IBOutlet UITableView *theTable;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) int offset;

- (IBAction)onClickCreate:(id)sender;
- (IBAction)onClickEdit:(id)sender;
- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickDelete:(id)sender;

@end

@implementation LocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFromNotification) name:NOTIFICATION_UPDATE_LOCATIONS object:nil];
    
    _offset = 0;
    _canLoadMore = YES;
    _isDownloading = NO;
    items = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self updateButtonsToMatchTableState];
    
    [self loadItems:NO withOffset:_offset];
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_theTable ins_removeInfinityScroll];
    [_theTable ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickCreate:(id)sender {
    [self performSegueWithIdentifier:@"SEGUE_CREATE_LOCATION" sender:nil];
}

- (IBAction)onClickEdit:(id)sender {
    [_theTable setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)onClickCancel:(id)sender {
    [_theTable setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)onClickDelete:(id)sender {
    [UIActionSheet showInView:self.view
                    withTitle:[NSString stringWithFormat:@"Are you sure you want to delete these items?"]
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"Delete"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if (buttonIndex == 0)
                             [self doDelete];
                     }];
}

#pragma mark - Deleting

- (void)doDelete {
    NSArray *selectedRows = [_theTable indexPathsForSelectedRows];
    
    if (selectedRows.count <= 0) {
        NSMutableArray *a = [NSMutableArray new];
        for (int i = 0; i < items.count; i++)
            [a addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        selectedRows = a;
    }
    
    NSMutableArray *idsToDelete = [NSMutableArray new];
    NSMutableIndexSet *indexPaths = [NSMutableIndexSet new];
    
    for (NSIndexPath *selectionIndex in selectedRows) {
        [idsToDelete addObject:@([items[selectionIndex.row] locationId])];
        [indexPaths addIndex:selectionIndex.row];
    }
    
    [GTLocationManager deleteLocations:idsToDelete successBlock:^(GTResponseObject *response) {
        
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
    
    // Locally delete items.
    [_theTable beginUpdates];
    
    [items removeObjectsAtIndexes:indexPaths];
    [_theTable deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationLeft];
    
    [_theTable endUpdates];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self checkNoItemsHeader];
        
        [_theTable setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    });
}

- (void)updateButtonsToMatchTableState {
    if (_theTable.editing) {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItems = @[cancelButton];
        
        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItems = @[deleteButton];
    }
    else {
        // Not in editing mode.
        self.navigationItem.leftBarButtonItems = nil;
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (items.count > 0)
            editButton.enabled = YES;
        else
            editButton.enabled = NO;

        self.navigationItem.rightBarButtonItems = @[createButton, editButton];
    }
}

- (void)updateDeleteButtonTitle {
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [_theTable indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == items.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
        deleteButton.title = NSLocalizedString(@"Delete All", @"");
    else {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Loading

- (void)refreshFromNotification {
    _offset = 0;
    _canLoadMore = YES;
    
    [self loadItems:YES withOffset:_offset];
}

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
    
    _isDownloading = YES;
    
    [GTLocationManager getLocationsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
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
    [loadingIndicator stopAnimating];
    
    _isDownloading = NO;
    [_theTable ins_endInfinityScroll];
    [_theTable ins_setInfinityScrollEnabled:_canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (_offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_theTable reloadData];
        
        [self checkNoItemsHeader];
        
        [self updateButtonsToMatchTableState];
    });
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
    if (!tableView.isEditing)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateButtonsToMatchTableState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateDeleteButtonTitle];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
    _theTable.allowsMultipleSelectionDuringEditing = YES;
    
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
