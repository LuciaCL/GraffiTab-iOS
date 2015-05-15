//
//  AppInfoViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 14/05/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController () {
    
    IBOutlet UIImageView *backButton;
    IBOutlet UIImageView *logo;
    IBOutlet UIView *infoView;
}

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self animateLogo];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (!self.navigationController.isNavigationBarHidden)
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

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Animations

- (void)animateLogo {
    [UIView animateWithDuration:0.5 animations:^{
        logo.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect f = logo.frame;
            f.origin.y -= IS_IPHONE_5 ? 130 : 100;
            logo.frame = f;
        } completion:^(BOOL finished) {
            [self animateInfo];
        }];
    }];
}

- (void)animateInfo {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        infoView.alpha = 1.0;
        
        CGRect f = infoView.frame;
        f.origin.y -= IS_IPHONE_5 ? 70 : 40;
        infoView.frame = f;
    } completion:^(BOOL finished) {
        [self animateRest];
    }];
}

- (void)animateRest {
    [UIView animateWithDuration:0.5 animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        backButton.alpha = 1.0;
    }];
}

#pragma mark - Setup

- (void)setupButtons {
    backButton.image = [backButton.image imageWithTint:[UIColor whiteColor]];
}

@end
