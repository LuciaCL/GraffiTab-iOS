//
//  CommentsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 28/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CommentsViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "CommentCell.h"
#import "UIActionSheet+Blocks.h"
#import "RTSpinKitView.h"
#import "AutocompleteHashCell.h"
#import "AutocompleteUserCell.h"

@interface CommentsViewController () {
    
    RTSpinKitView *loadingIndicator;
    
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
    GTComment *toEdit;
    
    NSArray *searchResult;
    NSMutableArray *autocompleteUsers;
    NSMutableArray *autocompleteHashtags;
}

@end

@implementation CommentsViewController

- (id)init {
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    
    if (self) {
        // Register a subclass of SLKTextView, if you need any special appearance and/or behavior customisation.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Register a subclass of SLKTextView, if you need any special appearance and/or behavior customisation.
    }
    
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    offset = 0;
    canLoadMore = YES;
    isDownloading = NO;
    items = [NSMutableArray new];
    autocompleteUsers = [NSMutableArray new];
    autocompleteHashtags = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupSlackController];
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self loadItems:YES withOffset:offset];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)dealloc {
    [self.tableView ins_removeInfinityScroll];
    [self.tableView ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickEdit {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)onClickEditComment:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        toEdit = items[indexPath.row];
        
        [self editText:toEdit.text];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
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
        self.tableView.tableHeaderView = nil;
    }
    
    [self showLoadingIndicator];
    
    isDownloading = YES;
    
    [GTStreamableManager getCommentsWithItemId:self.item.streamableId start:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
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
    
    [self.tableView reloadData];
}

- (void)finalizeLoad {
    [self.tableView ins_endPullToRefresh];
    [self removeLoadingIndicator];
    [loadingIndicator stopAnimating];
    
    isDownloading = NO;
    [self.tableView ins_endInfinityScroll];
    [self.tableView ins_setInfinityScrollEnabled:canLoadMore];
    
    [self findAutocompletes];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
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
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onClickEdit)];
    
    if (!self.embedded)
        [self.navigationItem setRightBarButtonItems:@[reload, edit] animated:YES];
    else
        self.navigationItem.rightBarButtonItems = nil;
}

- (void)checkNoItemsHeader {
    if (items.count <= 0) {
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"No items found";
        l.textColor = [UIColor lightGrayColor];
        l.font = [UIFont systemFontOfSize:15];
        l.transform = self.tableView.transform;
        self.tableView.tableHeaderView = l;
    }
    else
        self.tableView.tableHeaderView = nil;
}

- (void)findAutocompletes {
    NSError* error = nil;
    NSRegularExpression *hashtagsRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:\\s|\\A)[##]+([A-Za-z0-9-_]+)" options:0 error:&error];
    
    for (GTComment *comment in items) {
        // Add any new usernames.
        if (![autocompleteUsers containsObject:comment.user])
            [autocompleteUsers addObject:comment.user];
        
        // Find and add any new hashtags.
        NSArray *matches = [hashtagsRegex matchesInString:comment.text options:0 range:NSMakeRange(0, comment.text.length)];

        for (NSTextCheckingResult *match in matches) {
            NSString *matchText = [comment.text substringWithRange:[match range]];
            NSString *matchText2 = [matchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *hashtag = [matchText2 stringByReplacingOccurrencesOfString:@"#"
                                                                     withString:@""];
            
            if (![autocompleteHashtags containsObject:hashtag])
                [autocompleteHashtags addObject:hashtag];
        }
    }
}

#pragma mark - Overriden Methods

- (void)didPressRightButton:(id)sender {
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    NSString *text = [self.textView.text copy];
    
    // Create new comment.
    GTComment *newComment = [GTComment new];
    newComment.itemId = self.item.streamableId;
    newComment.user = [GTLifecycleManager user];
    newComment.text = text;
    newComment.date = [NSDate date];
    
    [GTStreamableManager postCommentWithText:text itemId:self.item.streamableId successBlock:^(GTResponseObject *response) {
        newComment.commentId = ((GTComment *) response.object).commentId;
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
    
    // Add the new message.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    [self.tableView beginUpdates];
    [items insertObject:newComment atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self checkNoItemsHeader];
    
    [self findAutocompletes];
    
    [super didPressRightButton:sender];
}

- (void)didCommitTextEditing:(id)sender {
    NSString *text = [self.textView.text copy];
    
    toEdit.text = text;
    
    [self.tableView reloadData];
    
    [GTStreamableManager editCommentWithId:toEdit.commentId text:text successBlock:^(GTResponseObject *response) {
        
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
    
    [self findAutocompletes];
    
    [super didCommitTextEditing:sender];
}

- (BOOL)canShowAutoCompletion {
    NSArray *array = nil;
    NSString *prefix = self.foundPrefix;
    NSString *word = self.foundWord;
    
    searchResult = nil;
    
    if ([prefix isEqualToString:@"@"]) {
        if (word.length > 0) {
            array = [autocompleteUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@", word]];
            
            if (array.count <= 0) {
                [GTSearchManager searchUsersWithQuery:word offset:0 numberOfItems:MAX_ITEMS successBlock:^(GTResponseObject *response) {
                    autocompleteUsers = response.object;
                    searchResult = [[NSMutableArray alloc] initWithArray:autocompleteUsers];
                    
                    [self.autoCompletionView reloadData];
                } failureBlock:^(GTResponseObject *response) {}];
            }
        }
        else
            array = autocompleteUsers;
    }
    else if ([prefix isEqualToString:@"#"]) {
        if (word.length > 0) {
            array = [autocompleteHashtags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
            
            if (array.count <= 0) {
                [GTSearchManager searchHashtagsWithQuery:word offset:0 numberOfItems:MAX_ITEMS successBlock:^(GTResponseObject *response) {
                    autocompleteHashtags = response.object;
                    searchResult = [[NSMutableArray alloc] initWithArray:autocompleteHashtags];
                    
                    [self.autoCompletionView reloadData];
                } failureBlock:^(GTResponseObject *response) {}];
            }
        }
        else
            array = autocompleteHashtags;
    }
    
    searchResult = [[NSMutableArray alloc] initWithArray:array];
    
    return YES;
}

- (CGFloat)heightForAutoCompletionView {
    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

    return cellHeight * searchResult.count;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView])
        return items.count;
    else
        return searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView])
        return [self messageCellForRowAtIndexPath:indexPath];
    else
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
}

- (CommentCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = (CommentCell *)[self.tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    cell.item = [items objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    // Cells must inherit the table view's transform
    // This is very important, since the main table view may be inverted
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (UITableViewCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if ([self.foundPrefix isEqualToString:@"@"]) {
        AutocompleteUserCell *c = (AutocompleteUserCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:@"AutocompleteUserCell"];
        
        c.item = searchResult[indexPath.row];
        
        cell = c;
    }
    else {
        AutocompleteHashCell *c = (AutocompleteHashCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:@"AutocompleteHashCell"];
        
        c.item = searchResult[indexPath.row];
        
        cell = c;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView]) {
        CommentCell *cell = (CommentCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        
        CGRect lhs = CGRectZero;
        lhs = CGRectUnion(lhs, cell.avatarView.frame);
        
        CGRect rhs = CGRectZero;
        rhs = CGRectUnion(rhs, cell.usernameLabel.frame);
        rhs = CGRectUnion(rhs, cell.messageTextLabel.frame);
        
        int finalHeight = MAX(lhs.size.height, rhs.size.height);
        
        return finalHeight + 5;
    }
    else if (tableView == self.autoCompletionView) {
        if ([self.foundPrefix isEqualToString:@"@"])
            return [AutocompleteUserCell height];
        else
            return [AutocompleteHashCell height];
    }
    
    return tableView.rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.autoCompletionView]) {
        UIView *topView = [UIView new];
        topView.backgroundColor = self.autoCompletionView.separatorColor;
        return topView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.autoCompletionView])
        return 0.5;

    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.tableView]) {
        GTComment *c = [items objectAtIndex:indexPath.row];
        GTPerson *u = [GTLifecycleManager user];
        
        NSArray *actions;
        
        if ([c.user isEqual:u])
            actions = @[@"Edit", @"Copy"];
        else
            actions = @[@"Copy"];
        
        [UIActionSheet showInView:self.view
                        withTitle:[NSString stringWithFormat:@"What would you like to do?"]
                cancelButtonTitle:@"Cancel"
           destructiveButtonTitle:nil
                otherButtonTitles:actions
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                                 return;
                             
                             if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit"])
                                 [self onClickEditComment:indexPath];
                             else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Copy"])
                                 [[UIPasteboard generalPasteboard] setString:c.text];
                         }];
    }
    else if ([tableView isEqual:self.autoCompletionView]) {
        NSString *string;
        if ([self.foundPrefix isEqualToString:@"@"])
            string = ((GTPerson *)searchResult[indexPath.row]).username;
        else
            string = searchResult[indexPath.row];
        
        NSMutableString *item = [string mutableCopy];
        [item appendString:@" "];
        
        [self acceptAutoCompletionWithString:item keepPrefix:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.autoCompletionView] || items.count <= 0)
        return NO;
    
    GTComment *c = [items objectAtIndex:indexPath.row];
    GTPerson *u = [GTLifecycleManager user];
    
    return [c.user isEqual:u];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.autoCompletionView])
        return;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTComment *c = [items objectAtIndex:indexPath.row];
        
        NSMutableArray *idsToDelete = [NSMutableArray arrayWithObject:@(c.commentId)];
        
        [GTStreamableManager deleteComments:idsToDelete successBlock:^(GTResponseObject *response) {
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

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important that if you ovveride this method, to call super.
    [super scrollViewDidScroll:scrollView];
}

/** UITextViewDelegate */
- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChangeSelection:(SLKTextView *)textView {
    [super textViewDidChangeSelection:textView];
}

#pragma mark - TweetProtocol

- (void)didClickHashtag:(NSString *)hashtag {
    if (self.embedded) {
        [self.parentPopover dismissPopoverAnimated:YES completion:^{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [ViewControllerUtils showSearchHashtag:hashtag fromViewController:[ViewControllerUtils getVisibleViewController]];
            }];
        }];
    }
    else
        [ViewControllerUtils showSearchHashtag:hashtag fromViewController:self];
}

- (void)didClickUsername:(NSString *)username {
    if (self.embedded) {
        [self.parentPopover dismissPopoverAnimated:YES completion:^{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [ViewControllerUtils showSearchUserProfile:username fromViewController:[ViewControllerUtils getVisibleViewController]];
            }];
        }];
    }
    else
        [ViewControllerUtils showSearchUserProfile:username fromViewController:self];
}

- (void)didClickAvatar:(GTPerson *)user {
    if (self.embedded) {
        [self.parentPopover dismissPopoverAnimated:YES completion:^{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
                [ViewControllerUtils showUserProfile:user fromViewController:[ViewControllerUtils getVisibleViewController]];
            }];
        }];
    }
    else
        [ViewControllerUtils showUserProfile:user fromViewController:self];
}

- (void)didClickLink:(NSString *)link {
    [Utils openUrl:link];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Comments";
}

- (void)setupSlackController {
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *messageCellNib = [UINib nibWithNibName:@"CommentCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:messageCellNib forCellReuseIdentifier:@"CommentCell"];
    
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textView.placeholder = @"Write your comment here";
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteUserCell"];
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteHashCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteHashCell"];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#"]];
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
    self.tableView.tableFooterView = [UIView new];
    
    // Setup pull-to-refresh
    [self.tableView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [self refresh];
    }];
    
    self.tableView.ins_pullToRefreshBackgroundView.preserveContentInset = NO;
    
    __strong typeof(self) weakSelf = self;
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        if (weakSelf->canLoadMore && !weakSelf->isDownloading) {
            weakSelf->offset += MAX_ITEMS;
            
            [weakSelf loadItems:NO withOffset:weakSelf->offset];
        }
        else {
            weakSelf->isDownloading = NO;
            
            [weakSelf.tableView ins_endInfinityScroll];
            [weakSelf.tableView ins_setInfinityScrollEnabled:NO];
        }
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSCircleInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    self.tableView.ins_infiniteScrollBackgroundView.preserveContentInset = NO;
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:CGRectMake(0, 0, 24, 24) backImage:nil frontImage:[UIImage imageNamed:@"iconFacebook"]];;
    self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.tableView.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
}

@end
