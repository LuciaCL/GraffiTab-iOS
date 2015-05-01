//
//  SocialFriendsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 27/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "SocialFriendsViewController.h"

@interface SocialFriendsViewController () {
    
    NSMutableArray *facebookFriendIds;
}

@end

@implementation SocialFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadFacebookFriends:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(GTResponseObject *))successBlock cacheBlock:(void (^)(GTResponseObject *))cacheBlock failureBlock:(void (^)(GTResponseObject *))failureBlock {
    if (!facebookFriendIds)
        return;
    
    [GTUserManager getFriendsListWithIds:facebookFriendIds start:o numberOfItems:MAX_ITEMS useCache:isStart successBlock:^(GTResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(GTResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(GTResponseObject *response) {
        failureBlock(response);
    }];
}

#pragma mark - Loading

- (void)loadFacebookFriends:(BOOL)start {
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        if (error)
            [self refresh];
        else {
            NSArray *fbFriends = [result objectForKey:@"data"];
            facebookFriendIds = [NSMutableArray new];
            
            for (NSDictionary<FBGraphUser>* friend in fbFriends)
                [facebookFriendIds addObject:friend.objectID];
            
            [self refresh];
        }
    }];
}

#pragma mark - Initialization

- (void)basicInit {
    self.title = @"Facebook friends";
}

@end
