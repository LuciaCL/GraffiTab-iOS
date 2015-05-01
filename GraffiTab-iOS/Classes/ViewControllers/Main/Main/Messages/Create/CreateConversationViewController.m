//
//  CreateConversationViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 03/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CreateConversationViewController.h"
#import "AutocompleteHashCell.h"
#import "AutocompleteUserCell.h"

@interface CreateConversationViewController () {
    
    IBOutlet UIView *toView;
    IBOutlet UITableView *toAutoCompleteTableView;
    IBOutlet UITextField *toField;
    
    NSArray *searchResult;
    NSMutableArray *autocompleteUsers;
    NSMutableArray *autocompleteHashtags;
}

- (IBAction)onClickCancel:(id)sender;

@end

@implementation CreateConversationViewController

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
    
    autocompleteUsers = [NSMutableArray new];
    autocompleteHashtags = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupSlackController];
    [self setupToField];
    [self setupAutocompleteTable];
    
    if (self.selectedUser)
        [self updateSelectedUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickCancel:(id)sender {
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateSelectedUser {
    if (self.selectedUser)
        toField.text = self.selectedUser.fullName;
}

#pragma mark - Overriden Methods

- (void)didPressRightButton:(id)sender {
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    [self.textView refreshFirstResponder];
    
    if (!self.selectedUser)
        [Utils showMessage:APP_NAME message:@"Please choose a recipient."];
    else {
        [self.view endEditing:YES];
        
        NSString *text = [self.textView.text copy];
        
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        NSMutableArray *receivers = [NSMutableArray arrayWithObject:@(self.selectedUser.userId)];
        [GTConversationManager createConversationWithText:text title:nil receiverIds:receivers image:nil successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
        
        [super didPressRightButton:sender];
    }
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
    if ([tableView isEqual:toAutoCompleteTableView] || [tableView isEqual:self.autoCompletionView])
        return searchResult.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:toAutoCompleteTableView])
        return [self toAutoCompletionCellForRowAtIndexPath:indexPath];
    else if ([tableView isEqual:self.autoCompletionView])
        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    
    return nil;
}

- (UITableViewCell *)toAutoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutocompleteUserCell *cell = (AutocompleteUserCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:@"AutocompleteUserCell"];
    
    cell.item = searchResult[indexPath.row];
    
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
    if (tableView == toAutoCompleteTableView)
        return [AutocompleteUserCell height];
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
    else if ([tableView isEqual:toAutoCompleteTableView]) {
        self.selectedUser = searchResult[indexPath.row];
        
        [self.view endEditing:YES];
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        toAutoCompleteTableView.alpha = 1.0;
        
        CGRect f = toAutoCompleteTableView.frame;
        f.size.height = self.view.frame.size.height - KEYBOARD_HEIGHT_IPHONE_P - f.origin.y;
        toAutoCompleteTableView.frame = f;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        toAutoCompleteTableView.alpha = 0.0;
        
        CGRect f = toAutoCompleteTableView.frame;
        f.size.height = self.view.frame.size.height - f.origin.y;
        toAutoCompleteTableView.frame = f;
    }];
    
    [self updateSelectedUser];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *word = [textField.text stringByAppendingString:string];
    
    NSArray *array;
    if (word.length > 0) {
        array = [autocompleteUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.username BEGINSWITH[c] %@ or self.fullName BEGINSWITH[c] %@", word, word]];
        
        if (array.count <= 0) {
            [GTSearchManager searchUsersWithQuery:word offset:0 numberOfItems:MAX_ITEMS successBlock:^(GTResponseObject *response) {
                autocompleteUsers = response.object;
                searchResult = [[NSMutableArray alloc] initWithArray:autocompleteUsers];
                
                [toAutoCompleteTableView reloadData];
            } failureBlock:^(GTResponseObject *response) {}];
        }
    }
    else
        array = autocompleteUsers;
    
    searchResult = [[NSMutableArray alloc] initWithArray:array];
    
    [toAutoCompleteTableView reloadData];
    
    return YES;
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Send a message";
}

- (void)setupToField {
    CGRect f = toView.frame;
    [toView removeFromSuperview];
    toView.frame = f;
    [self.view addSubview:toView];
}

- (void)setupSlackController {
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    self.tableView.hidden = YES;
    
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
    [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    [self.textInputbar.editortRightButton setTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textView.placeholder = @"Write your message here";
    self.shouldClearTextAtRightButtonPress = NO;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteUserCell"];
    [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteHashCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteHashCell"];
    [self registerPrefixesForAutoCompletion:@[@"@", @"#"]];
}

- (void)setupAutocompleteTable {
    toAutoCompleteTableView.alpha = 0.0;
}

@end
