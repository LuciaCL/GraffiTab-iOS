//
//  MessagesViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MessagesViewController.h"
#import "UIScrollView+INSPullToRefresh.h"
#import "INSCircleInfiniteIndicator.h"
#import "INSDefaultPullToRefresh.h"
#import "MessageCell.h"
#import "UIActionSheet+Blocks.h"
#import "RTSpinKitView.h"
#import "AutocompleteHashCell.h"
#import "AutocompleteUserCell.h"
#import "ConversationSettingsViewController.h"

#define TAG_TITLE 1
#define TAG_SUBTITLE 2

@interface MessagesViewController () {
    
    RTSpinKitView *loadingIndicator;
    
    BOOL isTyping;
    BOOL canLoadMore;
    BOOL isDownloading;
    NSMutableArray *items;
    int offset;
    GTConversationMessage *toEdit;
    NSTimer *typingTimer;
    
    NSArray *searchResult;
    NSMutableArray *autocompleteUsers;
    NSMutableArray *autocompleteHashtags;
}

@end

@implementation MessagesViewController

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
    
    isTyping = NO;
    offset = 0;
    canLoadMore = YES;
    isDownloading = NO;
    items = [NSMutableArray new];
    autocompleteUsers = [NSMutableArray new];
    autocompleteHashtags = [NSMutableArray new];
    
    [self setupSlackController];
    [self setupLoadingIndicator];
    [self setupTableView];
    
    [self loadItems:YES withOffset:offset];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    [self setupTopBar];
}

- (void)dealloc {
    [self.tableView ins_removeInfinityScroll];
    [self.tableView ins_removePullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SEGUE_CONVERSATION_SETTINGS"]) {
        ConversationSettingsViewController *vc = segue.destinationViewController;
        vc.conversation = self.conversation;
    }
}

#pragma mark - Process push notifications

- (void)processMessageNotification:(NSDictionary *)userInfo {
    long conversationId = [userInfo[@"conversationId"] longLongValue];

    if (conversationId == self.conversation.conversationId) // We're receiving something for the current chat so refresh the items.
        [self refresh];
}

- (void)processShowTypingIndicatorNotification:(NSDictionary *)userInfo {
    long conversationId = [userInfo[@"conversationId"] longLongValue];
    long typingUserId = [userInfo[@"typingUserId"] longLongValue];
    GTPerson *typingUser = [self.conversation findMemberForId:typingUserId];
    if (conversationId == self.conversation.conversationId) { // We're receiving something for the current chat so refresh the items.
        
        if (typingUser)
            [self.typingIndicatorView insertUsername:typingUser.firstname];
    }
}

- (void)processHideTypingIndicatorNotification:(NSDictionary *)userInfo {
    long conversationId = [userInfo[@"conversationId"] longLongValue];
    long typingUserId = [userInfo[@"typingUserId"] longLongValue];
    GTPerson *typingUser = [self.conversation findMemberForId:typingUserId];
    
    if (conversationId == self.conversation.conversationId) { // We're receiving something for the current chat so refresh the items.
        if (typingUser)
            [self.typingIndicatorView removeUsername:typingUser.firstname];
    }
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
    
    isDownloading = YES;
    
    [GTConversationManager getMessagesWithConversationId:self.conversation.conversationId start:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
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
    
    [self.tableView reloadData];
}

- (void)finalizeLoad {
    [self.tableView ins_endPullToRefresh];
    [loadingIndicator stopAnimating];
    
    isDownloading = NO;
    [self.tableView ins_endInfinityScroll];
    [self.tableView ins_setInfinityScrollEnabled:canLoadMore];
    
    // Delay execution of my block for x seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (offset == 1 ? 0.3 : 0.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        [self checkNoItemsHeader];
    });
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

#pragma mark - Overriden Methods

- (void)didPressRightButton:(id)sender {
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    NSString *text = [self.textView.text copy];
    
    // Create new message.
    GTConversationMessage *newMessage = [GTConversationMessage new];
    newMessage.conversationId = self.conversation.conversationId;
    newMessage.user = [GTLifecycleManager user];
    newMessage.text = text;
    newMessage.date = [NSDate date];
    newMessage.seenByUsers = [NSMutableArray arrayWithObject:[GTLifecycleManager user]];
    newMessage.state = ACTIVE;

    [GTConversationManager postMessageWithText:text conversationId:self.conversation.conversationId successBlock:^(GTResponseObject *response) {
        newMessage.messageId = ((GTConversationMessage *) response.object).messageId;
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
            [Utils showMessage:APP_NAME message:response.message];
    }];

    // Add the new message.
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
    
    [self.tableView beginUpdates];
    [items insertObject:newMessage atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
    
    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self checkNoItemsHeader];
    
    [super didPressRightButton:sender];
    
    [self sendHideTypingIndicator];
}

- (void)didCommitTextEditing:(id)sender {
    NSString *text = [self.textView.text copy];
    
    toEdit.text = text;
    
    NSInteger index = [items indexOfObject:toEdit];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [GTConversationManager editMessageWithId:toEdit.messageId text:text successBlock:^(GTResponseObject *response) {
        
    } failureBlock:^(GTResponseObject *response) {
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
            [Utils showMessage:APP_NAME message:response.message];
    }];
    
    [super didCommitTextEditing:sender];
    
    [self sendHideTypingIndicator];
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

- (MessageCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = (MessageCell *)[self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    
    GTConversationMessage *current = [items objectAtIndex:indexPath.row];
    
    // Configure author label visibility.
    if (indexPath.row < items.count - 1) {
        GTConversationMessage *next = [items objectAtIndex:indexPath.row + 1];
        
        cell.authorLabel.hidden = [current.user isEqual:next.user];
    }
    
    // Configure seen label visibility.
    if (self.conversation.members.count == 1)
        cell.seenByLabel.hidden = YES;
    else if ([current.user isEqual:[GTLifecycleManager user]] && indexPath.row == 0)
        cell.seenByLabel.hidden = NO;
    else {
        if (self.conversation.members.count > 2 && indexPath.row == 0)
            cell.seenByLabel.hidden = NO;
        else
            cell.seenByLabel.hidden = YES;
    }
    
    cell.conversation = self.conversation;
    cell.item = current;
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
        MessageCell *cell = (MessageCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        
        CGRect rhs = CGRectZero;
        rhs = CGRectUnion(rhs, cell.balloonView.frame);
        
        if (!cell.authorLabel.hidden)
            rhs = CGRectUnion(rhs, cell.authorLabel.frame);
        
        if (!cell.seenByLabel.hidden)
            rhs = CGRectUnion(rhs, cell.seenByLabel.frame);
        
        int finalHeight = rhs.size.height;
        
        if (cell.seenByLabel.hidden)
            finalHeight += 10;
        
        if (indexPath.row == 0)
            finalHeight += 5;
        
        return finalHeight;
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
    
    if ([tableView isEqual:self.autoCompletionView]) {
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

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIMenuItem *testMenuItem = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(edit:)];
    [[UIMenuController sharedMenuController] setMenuItems: @[testMenuItem]];
    [[UIMenuController sharedMenuController] update];
    
    if ([tableView isEqual:self.autoCompletionView] || items.count <= 0)
        return NO;
    
    GTConversationMessage *c = [items objectAtIndex:indexPath.row];
    
    return c.state != DELETED;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {

    GTConversationMessage *c = [items objectAtIndex:indexPath.row];
    GTPerson *u = [GTLifecycleManager user];
    
    if (action == @selector(copy:))
        return YES;
    else if ([c.user isEqual:u]) {
        if (action == @selector(delete:) && c.state != DELETED)
            return YES;
        if (action == @selector(edit:))
            return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:))
        [self onCopy:items[indexPath.row]];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important that if you ovveride this method, to call super.
    [super scrollViewDidScroll:scrollView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(SLKTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChangeSelection:(SLKTextView *)textView {
    [super textViewDidChangeSelection:textView];
    
    if (typingTimer) {
        [typingTimer invalidate];
        typingTimer = nil;
    }
    
    if (textView.text.length > 0) {
        [self sendShowTypingIndicator];
        
        // Setup timer.
        typingTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendHideTypingIndicator) userInfo:nil repeats:NO];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self sendHideTypingIndicator];
}

#pragma mark - Typing indicator

- (void)sendShowTypingIndicator {
    if (!isTyping) {
        isTyping = YES;
        
        [GTConversationManager showTypingIndicatorForConversationId:self.conversation.conversationId successBlock:^(GTResponseObject *response) {} failureBlock:^(GTResponseObject *response) {}];
    }
}

- (void)sendHideTypingIndicator {
    if (isTyping) {
        isTyping = NO;
        
        [GTConversationManager hideTypingIndicatorForConversationId:self.conversation.conversationId successBlock:^(GTResponseObject *response) {} failureBlock:^(GTResponseObject *response) {}];
    }
}

#pragma mark - EditCellProtocol

- (void)onCopy:(id)sender {
    GTConversationMessage *c = sender;
    
    [[UIPasteboard generalPasteboard] setString:c.text];
}

- (void)onEdit:(id)sender {
    toEdit = sender;
    
    [self editText:toEdit.text];
    
    NSInteger index = [items indexOfObject:toEdit];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)onDelete:(id)sender {
    [DialogBuilder buildYesNoDialogWithTitle:APP_NAME message:@"Are you sure you want to delete this message?" yesTitle:@"Yes" noTitle:@"No" yesBlock:^{
        GTConversationMessage *c = sender;
        
        NSMutableArray *idsToDelete = [NSMutableArray arrayWithObject:@(c.messageId)];
        
        [GTConversationManager deleteMessages:idsToDelete successBlock:^(GTResponseObject *response) {
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
        c.state = DELETED;
        NSInteger index = [items indexOfObject:c];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [self checkNoItemsHeader];
    } noBlock:^{
        
    }];
}

#pragma mark - TweetProtocol

- (void)didClickHashtag:(NSString *)hashtag {
    [ViewControllerUtils showSearchHashtag:hashtag fromViewController:self];
}

- (void)didClickUsername:(NSString *)username {
    [ViewControllerUtils showSearchUserProfile:username fromViewController:self];
}

- (void)didClickAvatar:(GTPerson *)user {
    [ViewControllerUtils showUserProfile:user fromViewController:self];
}

- (void)didClickLink:(NSString *)link {
    [Utils openUrl:link];
}

#pragma mark - Setup

- (void)setupTopBar {
    int width = 200;
    NSString *title;
    NSString *subtitle;
    
    NSMutableArray *otherMembers = [self.conversation findOtherMembers];
    
    if (otherMembers.count == 1) { // Chat with a single user.
        if (self.conversation.name) {
            title = self.conversation.name;
            subtitle = [[otherMembers lastObject] fullName];
        }
        else {
            title = [[otherMembers lastObject] fullName];
            subtitle = [[otherMembers lastObject] mentionUsername];
        }
    }
    else { // Chat with a group of users.
        if (self.conversation.name) {
            title = self.conversation.name;
            subtitle = self.conversation.getGroupChatTitle;
        }
        else {
            title = self.conversation.getGroupChatTitle;
            subtitle = [NSString stringWithFormat:@"%li members", self.conversation.members.count];
        }
    }
    
    if ([self.navigationItem.titleView viewWithTag:TAG_TITLE]) {
        UILabel *titleView = (UILabel *)[self.navigationItem.titleView viewWithTag:TAG_TITLE];
        UILabel *subtitleView = (UILabel *)[self.navigationItem.titleView viewWithTag:TAG_SUBTITLE];
        
        titleView.text = title;
        subtitleView.text = subtitle;
    }
    else {
        // Setup title/subtitle.
        CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, width, 44);
        UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
        _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
        _headerTitleSubtitleView.autoresizesSubviews = NO;
        
        CGRect titleFrame = CGRectMake(0, 2, width, 24);
        UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont systemFontOfSize:20];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = self.navigationController.navigationBar.tintColor;
        titleView.text = title;
        titleView.adjustsFontSizeToFitWidth = YES;
        titleView.tag = TAG_TITLE;
        [_headerTitleSubtitleView addSubview:titleView];
        
        CGRect subtitleFrame = CGRectMake(0, 24, width, 44-24);
        UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
        subtitleView.backgroundColor = [UIColor clearColor];
        subtitleView.font = [UIFont systemFontOfSize:11];
        subtitleView.textAlignment = NSTextAlignmentCenter;
        subtitleView.textColor = self.navigationController.navigationBar.tintColor;
        subtitleView.text = subtitle;
        subtitleView.adjustsFontSizeToFitWidth = YES;
        subtitleView.tag = TAG_SUBTITLE;
        [_headerTitleSubtitleView addSubview:subtitleView];
        
        self.navigationItem.titleView = _headerTitleSubtitleView;
    }
}

- (void)setupSlackController {
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    self.typingIndicatorView.interval = 60.0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *messageCellNib = [UINib nibWithNibName:@"MessageCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:messageCellNib forCellReuseIdentifier:@"MessageCell"];
    
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textView.placeholder = @"Write a message here";
    
    self.typingIndicatorView.backgroundColor = [UIColor clearColor];
    UIImageView *pencil = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 15, 15)];
    pencil.image = [UIImage imageNamed:@"typing.png"];
    [self.typingIndicatorView addSubview:pencil];
    
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteUserCell"];
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteHashCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteHashCell"];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#"]];
}

- (void)setupLoadingIndicator {
    loadingIndicator = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleChasingDots color:UIColorFromRGB(COLOR_MAIN)];
    loadingIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:loadingIndicator];
    
    CGPoint c = self.view.center;
    loadingIndicator.center = c;
}

- (void)setupTableView {
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Setup background.
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bkg.jpg"]];
    [tempImageView setFrame:CGRectMake(0, STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - (STATUSBAR_HEIGHT + NAVIGATIONBAR_HEIGHT + self.textInputbar.frame.size.height))];
    tempImageView.clipsToBounds = YES;
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempImageView.layer.zPosition = self.tableView.layer.zPosition - 1;
    [self.view addSubview:tempImageView];
    
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
