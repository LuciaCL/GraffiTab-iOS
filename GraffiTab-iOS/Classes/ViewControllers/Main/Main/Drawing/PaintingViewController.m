//
//  PaintingViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "PaintingViewController.h"
#import "PaintingView.h"
#import "SoundEffect.h"
#import "MyLocationManager.h"
#import "UIActionSheet+Blocks.h"
#import "ImageCropViewController.h"

#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight			30
#define kPaletteSize			5
#define kMinEraseInterval		0.5

#define INDEX_CLOSE 0
#define INDEX_CREATE 1
#define INDEX_CHANGE_BACKGROUND 2
#define INDEX_AVIARY 3
#define INDEX_COLOR 4
#define INDEX_CAP 5
#define INDEX_STORE 6

static NSString * const kAVYAviaryAPIKey = @"s6OqtUb_oU6MTYtIv_wugg";
static NSString * const kAVYAviarySecret = @"nESKzmp46kSvNDlgi0_CfA";

@interface PaintingViewController () {
    
    IBOutlet PaintingView *paintingView;
    IBOutlet UIImageView *backgroundImage;
    
    UIImagePickerController *galleryPicker;
    
    SoundEffect	*erasingSound;
    CFTimeInterval lastTime;
    CGPoint lastDragPoint;
}

@end

@implementation PaintingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupInitialValues];
    
    if (self.toEdit)
        backgroundImage.image = self.toEditImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onClickEnhance {
    UIImage *i = [self getMergedImage];
    
    [self launchPhotoEditorWithImage:i highResolutionImage:nil];
}

- (void)onClickClose {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:@"Save and close" actionBlock:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self captureToPhotoAlbum];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    [alert addButton:@"Close" actionBlock:^(void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    
    [alert showTitle:self title:APP_NAME subTitle:@"Are you sure you want to close this without saving it first?" style:Notice closeButtonTitle:@"Cancel" duration:0.0f];
}

- (void)onClickChangeBackground {
    [UIActionSheet showInView:self.view
                    withTitle:@"Choose source"
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
            otherButtonTitles:@[@"Take new", @"Choose from Library"]
                     tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                         if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
                             return;
                         
                         if (buttonIndex == 0)
                             [self doTakeNew];
                         else if (buttonIndex == 1)
                             [self doChooseFromGallery];
                     }];
}

- (void)onClickCreate {
    UIImage *i = [self getMergedImage];
    CLLocation *location = [MyLocationManager sharedInstance].lastLocation;
    
    if (location) {
        [[LoadingViewManager getInstance] addLoadingToView:self.view withMessage:@"Processing..."];
        
        void (^successBlock)(GTResponseObject *response) = ^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (self.toEdit)
                [Utils showMessage:APP_NAME message:@"Your graffiti was editted successfully."];
            else
                [Utils showMessage:APP_NAME message:@"Your graffiti was created successfully."];
        };
        void (^failureBlock)(GTResponseObject *response) = ^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else
                [Utils showMessage:APP_NAME message:response.message];
        };
        
        if (self.toEdit)
            [GTStreamableManager editTagWithId:self.toEdit.streamableId image:i location:location successBlock:successBlock failureBlock:failureBlock];
        else
            [GTStreamableManager createTagWithImage:i location:location successBlock:successBlock failureBlock:failureBlock];
    }
    else
        [Utils showMessage:APP_NAME message:@"We couldn't locate you. Please enable Location Services and try again."];
}

#pragma mark - Background change

- (void)doTakeNew {
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
        [Utils showMessage:APP_NAME message:@"No camera app was found on this device."];
    else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [NSArray arrayWithObjects:
                             (NSString *) kUTTypeImage,
                             nil];
        
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

- (void)doChooseFromGallery {
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] )
        [Utils showMessage:APP_NAME message:@"No gallery app was found on this device."];
    else {
        galleryPicker = [[UIImagePickerController alloc] init];
        galleryPicker.delegate = self;
        galleryPicker.allowsEditing = NO;
        galleryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        galleryPicker.mediaTypes = [NSArray arrayWithObjects:
                                    (NSString *) kUTTypeImage,
                                    nil];
        
        [self presentViewController:galleryPicker animated:YES completion:nil];
    }
}

- (UIImage *)getMergedImage {
    UIImage *blendedImage = nil;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundImage.bounds];
    imageView.image = backgroundImage.image;
    imageView.contentMode = backgroundImage.contentMode;
    
    UIImageView *subView = [[UIImageView alloc] initWithImage:[paintingView glToUIImage]];
    [imageView addSubview:subView];
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

#pragma mark - Painting methods

- (void)eraseView {
    if(CFAbsoluteTimeGetCurrent() > lastTime + kMinEraseInterval) {
        [erasingSound play];
        [paintingView erase];
        lastTime = CFAbsoluteTimeGetCurrent();
    }
}

- (void)captureToPhotoAlbum {
    UIImage *image = [self getMergedImage];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

#pragma mark Motion

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        // User was shaking the device. Post a notification named "shake".
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

- (void)dragging:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan)
        lastDragPoint = [gesture locationInView:gesture.view];
    
    CGPoint newCoord = [gesture locationInView:gesture.view];
    float dX = newCoord.x-lastDragPoint.x;
    float dY = newCoord.y-lastDragPoint.y;
    
    float xOrigin = gesture.view.frame.origin.x+dX;
    float yOrigin = gesture.view.frame.origin.y+dY;
    float widthOrigin = xOrigin + gesture.view.frame.size.width;
    float heightOrigin = yOrigin + gesture.view.frame.size.height;
    
    if (xOrigin < 0)
        xOrigin = 0;
    if (yOrigin < 0)
        yOrigin = 0;
    if (widthOrigin > self.view.frame.size.width)
        xOrigin = self.view.frame.size.width - gesture.view.frame.size.width;
    if (heightOrigin > self.view.frame.size.height)
        yOrigin = self.view.frame.size.height - gesture.view.frame.size.height;
        
    gesture.view.frame = CGRectMake(xOrigin, yOrigin, gesture.view.frame.size.width, gesture.view.frame.size.height);
}

#pragma mark - Aviary configuration methods

- (void)launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage {
    // Customize the editor's apperance. The customization options really
    // only need to be set once in this case since they are never changing,
    // so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AVYPhotoEditorController * photoEditor = [[AVYPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with
    // the image and the photo editor.
    if (highResImage) {
        [self setupHighResRenderForPhotoEditor:photoEditor
                                     withImage:highResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor
                       animated:YES
                     completion:nil];
}

- (void)setupHighResRenderForPhotoEditor:(AVYPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage {
    // Enqueue the render with the high resolution image. The render will asynchonously apply all changes made in the editor on
    // the provided image. It will not complete until some point after the editor closes. When rendering completes, the completion block
    // will be called on the main thread with the resulting image. If the user cancels or no edits were made, then the result will be `nil`
    // and the error parameter will provide a description of the error that occured.
    
    id<AVYPhotoEditorRender> render = [photoEditor enqueueHighResolutionRenderWithImage:highResImage
                                                                             completion:^(UIImage *result, NSError *error) {
                                                                                 if (result) {
                                                                                     UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
                                                                                 } else {
                                                                                     NSLog(@"High-res render failed with error : %@", error);
                                                                                 }
                                                                             }];
    
    
    // Provide a block to receive updates about the status of the render. This block will be called potentially multiple times, always
    // from the main thread.
    
    [render setProgressHandler:^(CGFloat progress) {
        NSLog(@"Render now %lf percent complete", round(progress * 100.0f));
    }];
}

- (void) setPhotoEditorCustomizationOptions {
    // Set API Key and Secret
    [AVYPhotoEditorController setAPIKey:kAVYAviaryAPIKey secret:kAVYAviarySecret];
    
    // Set Tool Order
    NSArray *toolOrder = @[kAVYEffects,
                           kAVYFocus,
                           kAVYFrames,
                           kAVYStickers,
                           kAVYEnhance,
                           kAVYColorAdjust,
                           kAVYLightingAdjust,
                           kAVYSplash,
                           kAVYText,
                           kAVYRedeye,
                           kAVYWhiten,
                           kAVYBlemish,
                           kAVYMeme];
    [AVYPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *supportedOrientations = @[@(UIInterfaceOrientationPortrait),
                                           @(UIInterfaceOrientationPortraitUpsideDown),
                                           @(UIInterfaceOrientationLandscapeLeft),
                                           @(UIInterfaceOrientationLandscapeRight)];
        [AVYPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *i = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
        UINavigationController *cropperNavigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"ImageCropViewController"];
        ImageCropViewController *cropper = cropperNavigation.viewControllers[0];
        
        cropper.checkBounds = YES;
        cropper.rotateEnabled = YES;
        cropper.doneCallback = ^(UIImage *editedImage, BOOL canceled) {
            if (!canceled)
                backgroundImage.image = editedImage;
            
            [cropperNavigation dismissViewControllerAnimated:YES completion:nil];
        };
        
        cropper.sourceImage = i;
        cropper.previewImage = i;
        
        [self presentViewController:cropperNavigation animated:YES completion:NULL];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            cropper.cropRect = paintingView.bounds;
            [cropper reset:YES];
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    picker = nil;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - AVYPhotoEditorControllerDelegate

- (void)photoEditor:(AVYPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    backgroundImage.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditorCanceled:(AVYPhotoEditorController *)editor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup

- (void)setupInitialValues {
    // Define a starting color
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    
    // Defer to the OpenGL view to set the brush color
    [paintingView setBrushColorWithRed:components[0] green:components[1] blue:components[2]];
    
    // Load the sounds
    NSBundle *mainBundle = [NSBundle mainBundle];
    erasingSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"Erase" ofType:@"caf"]];
    
    // Erase the view when recieving a notification named "shake" from the NSNotificationCenter object
    // The "shake" nofification is posted by the PaintingWindow object when user shakes the device
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eraseView) name:@"shake" object:nil];
}

@end
