//
//  CreditsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 15/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "CreditsViewController.h"
#import "CreditsLibrary.h"

@interface CreditsViewController () {
    
    NSMutableArray *items;
}

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    items = [NSMutableArray new];
    
    [self setupTopBar];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
}

#pragma mark - Loading

- (void)loadData {
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"credits" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:filePath];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *jsonArray = (NSArray *) json;
    
    for (NSDictionary *creditLibraryJson in jsonArray) {
        CreditsLibrary *l = [[CreditsLibrary alloc] initFromJson:creditLibraryJson];
        [items addObject:l];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
            
            break;
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CreditCell"];
            
            CreditsLibrary *item = items[indexPath.row];
            
            cell.textLabel.text = item.title;
            
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = tableView.rowHeight;
    
    switch (indexPath.section) {
        case 0: {
            h = 75;
            
            break;
        }
        case 1: {
            h = 44;
            
            break;
        }
    }
    
    return h;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return @"Software Libraries";
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
        [Utils openUrl:[items[indexPath.row] url]];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Credits";
}

@end
