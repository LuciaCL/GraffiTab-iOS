//
//  ConversationsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "ConversationsViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "ConversationCell.h"
#import "MessagesViewController.h"
#import "RTSpinKitView.h"
#import "MGSwipeButton.h"

@interface ConversationsViewController () {
    
    IBOutlet UITableView *theTable;
    
    RTSpinKitView *loadingIndicator;
    
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
}

@end

@implementation ConversationsViewController

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

- (void)dealloc {
    [theTable ins_removeInfinityScroll];
    [theTable ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickCompose {
    [self performSegueWithIdentifier:@"SEGUE_COMPOSE_MESSAGE" sender:nil];
}

- (void)onClickLeaveConversation:(NSIndexPath *)indexPath {
    [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to leave this conversation?" yesTitle:@"Yes" noTitle:@"No" yesBlock:^{
        GTConversation *c = [items objectAtIndex:indexPath.row];
        
        [GTConversationManager leaveConversation:c.conversationId successBlock:^(GTResponseObject *response) {
            [self checkNoItemsHeader];
        } failureBlock:^(GTResponseObject *response) {
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
        
        // Delete item instantly.
        [items removeObjectAtIndex:indexPath.row];
        [theTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self checkNoItemsHeader];
    } noBlock:^{
        
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SEGUE_SHOW_MESSAGES"]) {
        MessagesViewController *vc = segue.destinationViewController;
        vc.conversation = sender;
    }
}

#pragma mark - Process push notifications

- (void)processMessageNotification:(NSDictionary *)userInfo {
    [self refresh];
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
    
    [GTConversationManager getConversationsWithStart:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
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
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
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
    
    [self.navigationItem setRightBarButtonItems:@[[[UIBarButtonItem alloc] initWithCustomView:indicator]] animated:YES];
}

- (void)removeLoadingIndicator {
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onClickCompose)];
    
    [self.navigationItem setRightBarButtonItems:@[create] animated:YES];
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
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell" forIndexPath:indexPath];
    
    cell.item = items[indexPath.row];
    
    // Add utility buttons.
    MGSwipeButton *btn = [MGSwipeButton buttonWithTitle:@"Leave" backgroundColor:UIColorFromRGB(0xFC3D38) callback:^BOOL(MGSwipeTableCell *sender) {
        [self onClickLeaveConversation:indexPath];
        
        return YES;
    }];
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray arrayWithObject:btn];
    cell.rightButtons = rightUtilityButtons;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    GTConversation *m = items[indexPath.row];

    if (m.unseenMessagesCount > 0)
        cell.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    else
        cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GTConversation *m = items[indexPath.row];
    
    [self performSegueWithIdentifier:@"SEGUE_SHOW_MESSAGES" sender:m];
    
    m.unseenMessagesCount = 0;
    [theTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Messages";
    
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
