//
//  STViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 31/03/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonViewController.h"
#import "FullSizeCellProtocol.h"
#import "RTSpinKitView.h"

typedef enum {
    STVIEW_TYPE_LARGE,
    STVIEW_TYPE_MEDIUM,
    STVIEW_TYPE_SMALL,
    STVIEW_TYPE_RANDOM,
} STViewType;

@interface STViewController : BackButtonViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FullSizeCellProtocol>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) RTSpinKitView *loadingIndicator;
@property (nonatomic, assign) STViewType viewType;

- (void)basicInit;
- (void)refresh;
- (void)layoutComponents;

- (void)showStreamableTag:(GTStreamableTag *)streamable;
- (void)showStreamableVideo:(GTStreamableVideo *)streamable;

- (void)showLoadingIndicator;
- (void)removeLoadingIndicator;

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock;

@end
