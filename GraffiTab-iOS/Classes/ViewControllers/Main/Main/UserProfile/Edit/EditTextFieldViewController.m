//
//  EditTextFieldViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 17/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "EditTextFieldViewController.h"

@interface EditTextFieldViewController () {
    
    IBOutlet UITextField *textField;
}

@end

@implementation EditTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickDone:(id)sender {
    NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!self.canBeEmpty && trimmedString.length <= 0) {
        [Utils showMessage:APP_NAME message:@"Please enter a value for this field."];
        return;
    }
    
    if (self.finishedEditingBlock)
        self.finishedEditingBlock(trimmedString);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadData {
    textField.text = self.defaultValue;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [textField becomeFirstResponder];
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [self onClickDone:nil];
    
    return YES;
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Edit";
    
    UIButton *useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    useButton.frame = CGRectMake(0, 0, 50, 30);
    useButton.layer.cornerRadius = 4;
    [useButton setTitle:@"Done" forState:UIControlStateNormal];
    useButton.backgroundColor = UIColorFromRGB(COLOR_ORANGE);
    [useButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    useButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [useButton addTarget:self action:@selector(onClickDone:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIBarButtonItem *useItem = [[UIBarButtonItem alloc] initWithCustomView:useButton];
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, useItem]];
}

@end
