//
//  USRViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonViewController.h"
#import "UserProtocol.h"
#import "RTSpinKitView.h"

@interface USRViewController : BackButtonViewController <UITableViewDataSource, UITableViewDelegate, UserProtocol>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) RTSpinKitView *loadingIndicator;

- (void)basicInit;

- (void)refresh;

- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock;

@end
