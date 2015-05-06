//
//  InfoViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 26/11/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController () {
    
    IBOutlet UIWebView *webview;
}

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)loadText {
    BOOL loaded = YES;
    
    if ( self.filePath ) {
        NSError *e;
        NSString *myText = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&e];
        
        if ( myText )
            [webview loadHTMLString:myText baseURL:nil];
        else {
            loaded = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        loaded = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ( !loaded )
        [[SCLAlertView new] showError:self title:APP_NAME subTitle:@"Couldn't load content. Please try again." closeButtonTitle:@"OK" duration:0.0f];
}

@end
