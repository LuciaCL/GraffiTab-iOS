//
//  SocialFriendsViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 27/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "SocialFriendsViewController.h"
#import "GetSocialFriends.h"

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

- (void)loadItems:(BOOL)isStart withOffset:(int)o successBlock:(void (^)(ResponseObject *))successBlock cacheBlock:(void (^)(ResponseObject *))cacheBlock failureBlock:(void (^)(ResponseObject *))failureBlock {
    
    if (!facebookFriendIds)
        return;
    
    GetSocialFriends *task = [GetSocialFriends new];
    task.isStart = isStart;
    [task getFriendsListWithIds:facebookFriendIds start:o numberOfItems:MAX_ITEMS successBlock:^(ResponseObject *response) {
        successBlock(response);
    } cacheBlock:^(ResponseObject *response) {
        cacheBlock(response);
    } failureBlock:^(ResponseObject *response) {
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
