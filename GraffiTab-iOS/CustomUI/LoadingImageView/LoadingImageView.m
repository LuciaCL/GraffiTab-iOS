//
//  LoadingImageView.m
//  CG210
//
//  Created by Georgi Christov on 11/22/13.
//  Copyright (c) 2013 Proxiad. All rights reserved.
//

#import "LoadingImageView.h"

@interface LoadingImageView () {
    
    NSString *currentUrl;
}

@end

@implementation LoadingImageView

@synthesize imageView;
@synthesize delegate;
@synthesize activityIndicator;
@synthesize forceLoad;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [self baseInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Initialization code
        [self baseInit];
    }
    
    return self;
}

- (void)baseInit {
    [self setUserInteractionEnabled:YES];
    [self setOpaque:YES];
    
    forceLoad = NO;
    
    // Setup image view.
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    // Add gesture recognizer to view.
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    rec.delegate = self;
    [imageView addGestureRecognizer:rec];
    rec = nil;
    
    // Setup activity indicator view.
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint center = CGPointMake(self.frame.size.width / 2, imageView.frame.size.height / 2);
    activityIndicator.center = center;
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:activityIndicator];
}

- (void)loadImageWithUrl:(NSString *)url thumbnailUrl:(NSString *)thumbnail {
    if (![currentUrl isEqualToString:url])
        imageView.image = nil;
    
    currentUrl = url;
    
    if (thumbnail) {
        [self loadImage:thumbnail showLoadingIndicator:YES successBlock:^{
            [self loadImage:url showLoadingIndicator:NO successBlock:nil failureBlock:nil];
        } failureBlock:^{
            [self loadImage:url showLoadingIndicator:YES successBlock:nil failureBlock:nil];
        }];
    }
    else
        [self loadImage:url showLoadingIndicator:YES successBlock:nil failureBlock:nil];
}

- (void)layoutSubviews {
    imageView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    CGPoint center = CGPointMake(self.frame.size.width / 2, imageView.frame.size.height / 2);
    activityIndicator.center = center;
}

- (void)setImage:(UIImage *)i {
    imageView.image = i;
}

- (void)singleTap:(UIGestureRecognizer *)recognizer {
    if ( delegate != nil && [delegate respondsToSelector:@selector(didTapOnImage:)] )
        [delegate didTapOnImage:imageView];
}

- (void)loadImage:(NSString *)url showLoadingIndicator:(BOOL)showIndicator successBlock:(void (^)(void))successBlock failureBlock:(void (^)(void))failureBlock {
    if (showIndicator)
        [activityIndicator startAnimating];
    else
        [activityIndicator stopAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    req.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    [imageView setImageWithURLRequest:req placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.imageView.image = image;
        [weakSelf.activityIndicator stopAnimating];
        
        if (successBlock)
            successBlock();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        weakSelf.imageView.image = [UIImage imageNamed:@"no_image_available.gif"];
        [weakSelf.activityIndicator stopAnimating];
        
        if (failureBlock)
            failureBlock();
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
