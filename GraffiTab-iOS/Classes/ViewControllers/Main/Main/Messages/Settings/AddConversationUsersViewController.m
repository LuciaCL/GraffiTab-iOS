//
//  AddConversationUsersViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AddConversationUsersViewController.h"
#import "AutocompleteUserCell.h"

@interface AddConversationUsersViewController () {
    
    IBOutlet UITableView *toAutoCompleteTableView;
    IBOutlet TITokenField *tokenField;
    
    NSArray *searchResult;
    NSMutableArray *autocompleteUsers;
}

- (IBAction)onClickSave:(id)sender;

@end

@implementation AddConversationUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    autocompleteUsers = [NSMutableArray new];
    
    [self setupTopBar];
    [self setupAutocompleteTable];
    [self setupToField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
}

- (IBAction)onClickSave:(id)sender {
    [self.view endEditing:YES];
    
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
    
    NSMutableArray *receivers = [NSMutableArray new];
    for (TIToken *token in tokenField.tokens)
        [receivers addObject:@(((GTPerson *)token.representedObject).userId)];
    
    [GTConversationManager addConversationUsersWithConversationId:self.conversation.conversationId receiverIds:receivers successBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        GTConversation *c = response.object;
        self.conversation.members = c.members;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } failureBlock:^(GTResponseObject *response) {
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self toAutoCompletionCellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)toAutoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AutocompleteUserCell *cell = (AutocompleteUserCell *)[toAutoCompleteTableView dequeueReusableCellWithIdentifier:@"AutocompleteUserCell"];
    
    cell.item = searchResult[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GTPerson *p = searchResult[indexPath.row];
    
    TIToken *token = [tokenField addTokenWithTitle:p.fullName representedObject:p];
    token.tintColor = UIColorFromRGB(COLOR_ORANGE);
}

#pragma mark - UITokenFieldDelegate

- (BOOL)tokenField:(TITokenField *)tf willAddToken:(TIToken *)token {
    return [token.representedObject isKindOfClass:[GTPerson class]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        toAutoCompleteTableView.alpha = 1.0;
        
        CGRect f = toAutoCompleteTableView.frame;
        f.origin.y = [tokenField frame].size.height + [tokenField frame].origin.y;
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
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *word = [textField.text stringByAppendingString:string];
    word = [word substringFromIndex:1];
    
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

- (void)tokenFieldFrameDidChange:(TITokenField *)tf {
    [UIView animateWithDuration:0.0
                     animations:^{
                         CGRect f = toAutoCompleteTableView.frame;
                         f.origin.y = [tokenField frame].size.height + [tokenField frame].origin.y;
                         f.size.height = self.view.frame.size.height - KEYBOARD_HEIGHT_IPHONE_P - f.origin.y;
                         toAutoCompleteTableView.frame = f;
                     }
                     completion:nil];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Add People";
}

- (void)setupAutocompleteTable {
    toAutoCompleteTableView.alpha = 0.0;
    [toAutoCompleteTableView registerNib:[UINib nibWithNibName:@"AutocompleteUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteUserCell"];
}

- (void)setupToField {
    tokenField.delegate = self;
    tokenField.backgroundColor = UIColorFromRGB(0xfbf3e8);
    [tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
    [tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [tokenField setPromptText:@"To:"];
    [tokenField setPlaceholder:@"Type people's names"];
}

@end
