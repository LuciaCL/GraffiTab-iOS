//
//  EditPasswordViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "EditPasswordViewController.h"

@interface EditPasswordViewController () {
    
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *newPasswordField;
    IBOutlet UITextField *confirmPasswordField;
}

@end

@implementation EditPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSave:(id)sender {
    [self.view endEditing:YES];
    
    NSString *p = passwordField.text;
    NSString *np = newPasswordField.text;
    NSString *cp = confirmPasswordField.text;
    
    if ([InputValidator validateEditPasswordInput:p newPassword:np confirmPassword:cp viewController:self.navigationController]) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        [GTUserManager editProfileWithPassword:p newPassword:np successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showTitle:self.navigationController title:APP_NAME subTitle:@"Password changed!" style:Success closeButtonTitle:@"OK" duration:0.0f];
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED)
                [[SCLAlertView new] showError:self.navigationController title:APP_NAME subTitle:@"Your password was incorrect." closeButtonTitle:@"OK" duration:0.0f];
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
        
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == passwordField)
        [newPasswordField becomeFirstResponder];
    else if (textField == newPasswordField)
        [confirmPasswordField becomeFirstResponder];
    else
        [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Edit";
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    useButton.frame = CGRectMake(0, 0, 50, 30);
    useButton.layer.cornerRadius = 4;
    [useButton setTitle:@"Save" forState:UIControlStateNormal];
    useButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    useButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [useButton addTarget:self action:@selector(onClickSave:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIBarButtonItem *useItem = [[UIBarButtonItem alloc] initWithCustomView:useButton];
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, useItem]];
}

@end
