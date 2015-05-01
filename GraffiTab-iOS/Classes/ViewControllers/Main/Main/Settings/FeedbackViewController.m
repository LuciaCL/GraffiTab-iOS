//
//  FeedbackViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController () {
    
    IBOutlet UITextView *textView;
}

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickSend {
    [self.view endEditing:YES];
    
    if (textView.text.length > 0) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        [GTFeedbackManager postFeedbackWithText:textView.text successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showTitle:self.navigationController title:APP_NAME subTitle:@"Thank you for your feedback!" style:Success closeButtonTitle:@"OK" duration:0.0f];
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Feedback";
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    useButton.frame = CGRectMake(0, 0, 50, 30);
    useButton.layer.cornerRadius = 4;
    [useButton setTitle:@"Send" forState:UIControlStateNormal];
    useButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    useButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [useButton addTarget:self action:@selector(onClickSend) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIBarButtonItem *useItem = [[UIBarButtonItem alloc] initWithCustomView:useButton];
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, useItem]];
}

@end
