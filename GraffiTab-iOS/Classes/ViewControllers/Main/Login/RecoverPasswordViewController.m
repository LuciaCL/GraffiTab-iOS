//
//  RecoverPasswordViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 25/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "RecoverPasswordViewController.h"

@interface RecoverPasswordViewController () {
    
    IBOutlet UITextField *emailField;
    IBOutlet UIImageView *emailIcon;
}

- (IBAction)onClickCancel:(id)sender;

@end

@implementation RecoverPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupImageViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"DEALLOC %@", self.class);
}

- (IBAction)onClickCancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClickReset {
    [self.view endEditing:YES];
    
    if ([InputValidator validateResetPasswordInput:emailField.text viewController:self]) {
        [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing"];
        
        [GTUserManager resetPasswordWithEmail:emailField.text successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert addButton:@"OK" actionBlock:^(void) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self onClickCancel:nil];
                });
            }];
            
            [alert showTitle:self.navigationController title:APP_NAME subTitle:@"Your password has been reset successfully. Please check your email and login." style:Success closeButtonTitle:nil duration:0.0f];
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == NOT_FOUND)
                [[SCLAlertView new] showError:self.navigationController title:APP_NAME subTitle:@"This email address was not found." closeButtonTitle:@"OK" duration:0.0f];
            else
                [[SCLAlertView new] showError:self.navigationController title:APP_NAME subTitle:@"We couldn't process your request right now. Please try again." closeButtonTitle:@"OK" duration:0.0f];
        }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0)
        [self onClickReset];
}

#pragma mark - Setup

- (void)setupImageViews {
    emailIcon.image = [emailIcon.image imageWithTint:UIColorFromRGB(COLOR_MAIN)];
}

@end
