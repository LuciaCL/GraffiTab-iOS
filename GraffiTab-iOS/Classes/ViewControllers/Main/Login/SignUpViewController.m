//
//  SignUpViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "SignUpViewController.h"
#import "InfoViewController.h"

@interface SignUpViewController () {
    
    IBOutlet UILabel *termsLabel;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *confirmPasswordField;
    IBOutlet UITextField *emailField;
    IBOutlet UITextField *firstnameField;
    IBOutlet UITextField *lastnameField;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *signupButton;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self setupLabels];
    [self setupTableView];
    [self setupButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (IBAction)onClickCancel:(id)sender {
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickSignup:(id)sender {
    [self.view endEditing:YES];
    
    if ([InputValidator validateSignupInput:usernameField.text password:passwordField.text confirmPassword:confirmPasswordField.text email:emailField.text firstname:firstnameField.text lastname:lastnameField.text viewController:self]) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        [GTUserManager signupWithUsername:usernameField.text password:passwordField.text email:emailField.text firstName:firstnameField.text lastName:lastnameField.text externalId:nil successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOG_IN object:nil];
            });
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == ALREADY_EXISTS)
                [Utils showMessage:APP_NAME message:@"This username or email have already been taken."];
            else
                [Utils showMessage:APP_NAME message:@"We couldn't process your request right now. Please try again."];
        }];
    }
}

- (void)onClickTerms {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    InfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    vc.filePath = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"];
    vc.title = @"Terms of Use";
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIImageView *iv = (UIImageView *)[cell.contentView viewWithTag:1];
        UITextField *tf = (UITextField *)[cell.contentView viewWithTag:2];
        
        if (iv && tf) {
            iv.image = [iv.image imageWithTint:[UIColor whiteColor]];
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tf.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
            
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(iv.frame.origin.x + 7, 44, cell.frame.size.width - (iv.frame.origin.x + 23), 1)];
            line.backgroundColor = [UIColor whiteColor];
            line.alpha = 0.4;
            [cell addSubview:line];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 7)
                [self onClickTerms];
            
            break;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == firstnameField)
        [lastnameField becomeFirstResponder];
    else if (textField == lastnameField)
        [usernameField becomeFirstResponder];
    else if (textField == usernameField)
        [passwordField becomeFirstResponder];
    else if (textField == passwordField)
        [confirmPasswordField becomeFirstResponder];
    else if (textField == confirmPasswordField)
        [emailField becomeFirstResponder];
    else if (textField == emailField)
        [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - Setup

- (void)setupLabels {
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    termsLabel.attributedText = [[NSAttributedString alloc] initWithString:termsLabel.text attributes:underlineAttribute];
}

- (void)setupTableView {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grafitab_login.png"]];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    self.tableView.backgroundView = iv;
}

- (void)setupButtons {
    signupButton.layer.cornerRadius = 3;

    cancelButton.layer.cornerRadius = 3;
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelButton.layer.borderWidth = 1;
    cancelButton.alpha = 0.8;
    
    [signupButton addTarget:self action:@selector(onClickSignup:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(onClickCancel:) forControlEvents:UIControlEventTouchUpInside];
}

@end
