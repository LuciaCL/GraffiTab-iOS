//
//  GraffitiMapViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 19/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "GraffitiMapViewController.h"
#import "RTSpinKitView.h"
#import "STTagThumbnail.h"
#import "STTagAnnotation.h"
#import "TSDemoClusteredAnnotationView.h"
#import "BlockActionSheet.h"
#import <AddressBookUI/AddressBookUI.h>
#import "MapThumbnailsViewController.h"

@interface GraffitiMapViewController () {
    
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *gridButton;
    IBOutlet UIButton *locateButton;
    IBOutlet UIView *segmentView;
    IBOutlet UIView *searchView;
    IBOutlet TSClusterMapView *myMapView;
    IBOutlet UITextField *searchField;
    
    NSMutableArray *items;
    NSMutableArray *annotations;
    BOOL isSearching;
    BOOL showedFirstUserLocation;
}

- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickSearch:(id)sender;
- (IBAction)onClickGrid:(id)sender;
- (IBAction)onClickLocate:(id)sender;

@end

@implementation GraffitiMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    items = [NSMutableArray new];
    annotations = [NSMutableArray new];
    
    [self setupMapView];
    [self setupButtons];
    
    if (self.location)
        [self zoomMapToLocation:self.location];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (!self.navigationController.isNavigationBarHidden)
        [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"DEALLOC %@", self.class);
#endif
    
    switch (myMapView.mapType) {
        case MKMapTypeHybrid:
            myMapView.mapType = MKMapTypeStandard;
            break;
        case MKMapTypeStandard:
            myMapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
    
    myMapView.showsUserLocation = NO;
    myMapView.delegate = nil;
    [myMapView removeFromSuperview];
    myMapView = nil;
}

- (IBAction)onClickBack:(id)sender {
    if (self.isModal)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onClickSearch:(id)sender {
    isSearching = !isSearching;
    
    if (isSearching) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect f = searchView.frame;
            f.origin.x = backButton.frame.origin.x + backButton.frame.size.width + 30;
            f.size.width = self.view.frame.size.width - f.origin.x - 10;
            searchView.frame = f;
            
            searchField.alpha = 1.0;
        } completion:^(BOOL finished) {
            [searchField becomeFirstResponder];
        }];
    }
    else {
        [self.view endEditing:YES];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect f = searchView.frame;
            f.size.width = backButton.frame.size.width;
            f.origin.x = self.view.frame.size.width - 10 - f.size.width;
            searchView.frame = f;
            
            searchField.alpha = 0.0;
        }];
    }
}

- (IBAction)onClickGrid:(id)sender {
    // First we need to calculate the corners of the map so we get the points.
    CGPoint nePoint = CGPointMake(myMapView.bounds.origin.x + myMapView.bounds.size.width, myMapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake(myMapView.bounds.origin.x, myMapView.bounds.origin.y + myMapView.bounds.size.height);
    
    // Then transform those point into lat, lng values
    CLLocationCoordinate2D neCoord = [myMapView convertPoint:nePoint toCoordinateFromView:myMapView];
    CLLocationCoordinate2D swCoord = [myMapView convertPoint:swPoint toCoordinateFromView:myMapView];
    
    UIStoryboard *mainStoryboard = [SlideNavigationController sharedInstance].storyboard;
    UINavigationController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MapThumbnailsViewController"];
    MapThumbnailsViewController *mapThumbs = vc.viewControllers.firstObject;
    mapThumbs.neCoord = neCoord;
    mapThumbs.swCoord = swCoord;
    
    int w = self.view.frame.size.width - 40;
    int h = 323;
    
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    // Setup popup sheet.
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleDropDown;
    formSheet.cornerRadius = 8.0;
    formSheet.presentedFormSheetSize = CGSizeMake(w, h);
    formSheet.shouldCenterVertically = YES;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (IBAction)onClickLocate:(id)sender {
    [self centerToLocation:myMapView.userLocation.location];
}

- (void)centerToLocation:(CLLocation *)location {
    [self zoomMapToLocation:location];
}

#pragma mark - Searching

- (void)searchLocationForAddress:(NSString *)address {
    [[LoadingViewManager getInstance] addLoadingToView:self.navigationController.view withMessage:@"Processing..."];
    
    MKLocalSearchRequest* request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = address;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *placemarks = response.mapItems; // array of MKMapItems
        
        [[LoadingViewManager getInstance] removeLoadingView];
        
        if (placemarks.count <= 0) {
            [Utils showMessage:APP_NAME message:@"No locations found for this address."];
            return;
        }
        
        if (placemarks.count > 1) {
            // More than one matches found, so ask user which one to use.
            
            BlockActionSheet *actionSheet = [[BlockActionSheet alloc] initWithTitle:@"Select address"];
            
            for (MKMapItem *mapItem in placemarks) {
                // Process the placemark.
                NSString *title = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, YES);
                
                [actionSheet addButtonWithTitle:ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, NO) block:^{
                    searchField.text = title;
                    
                    [self zoomMapToLocation:mapItem.placemark.location];
                }];
            }
            
            [actionSheet addButtonWithTitle:@"Cancel" block:nil];
            [actionSheet showInView:self.view];
        }
        else {
            // Only one match found, so use it.
            MKMapItem *mapItem = [placemarks objectAtIndex:0];
            
            [self zoomMapToLocation:mapItem.placemark.location];
        }
    }];
}

- (void)zoomMapToLocation:(CLLocation *)location {
    MKCoordinateRegion mapRegion;
    mapRegion.center = location.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [myMapView setRegion:mapRegion animated:YES];
}

#pragma mark - Loading

- (void)loadItems {
    // First we need to calculate the corners of the map so we get the points.
    CGPoint nePoint = CGPointMake(myMapView.bounds.origin.x + myMapView.bounds.size.width, myMapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake(myMapView.bounds.origin.x, myMapView.bounds.origin.y + myMapView.bounds.size.height);
    
    // Then transform those point into lat, lng values
    CLLocationCoordinate2D neCoord = [myMapView convertPoint:nePoint toCoordinateFromView:myMapView];
    CLLocationCoordinate2D swCoord = [myMapView convertPoint:swPoint toCoordinateFromView:myMapView];
    
    int o = 0;
    
    [GTStreamableManager getForLocationWithNECoordinate:neCoord SWCoordinate:swCoord start:o numberOfItems:50 successBlock:^(GTResponseObject *response) {
        [self processAnnotations:response.object];
        
        [self finalizeLoad];
    } failureBlock:^(GTResponseObject *response) {
        [self finalizeLoad];

        if (response.reason == AUTHORIZATION_NEEDED) {
            [Utils logoutUserAndShowLoginController];
            [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
        }
        else
            [Utils showMessage:APP_NAME message:response.message];
    }];
}

- (void)finalizeCacheLoad {
    [myMapView addClusteredAnnotations:annotations];
    
    [self downloadImagesAndRefresh];
}

- (void)finalizeLoad {
    [myMapView addClusteredAnnotations:annotations];
    [self downloadImagesAndRefresh];
}

- (void)processAnnotations:(NSMutableArray *)streamables {
    __weak typeof(self) weakSelf = self;
    
    for (GTStreamable *item in streamables) {
        if (![items containsObject:item]) {
            if (item.type == TAG) {
                GTStreamableTag *tag = (GTStreamableTag *) item;
                
                STTagThumbnail *thumbnail = [STTagThumbnail new];
                thumbnail.title = tag.user.fullName;
                thumbnail.subtitle = tag.user.mentionUsername;
                thumbnail.coordinate = CLLocationCoordinate2DMake(tag.latitude, tag.longitude);
                thumbnail.disclosureBlock = ^{
                    [ViewControllerUtils showTag:tag fromViewController:weakSelf];
                };
                
                STTagAnnotation *annotation = [STTagAnnotation annotationWithThumbnail:thumbnail];
                annotation.item = tag;
                
                [annotations addObject:annotation];
            }
            
            [items addObject:item];
        }
    }
}

- (void)downloadImagesAndRefresh {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (STTagAnnotation *annotation in annotations) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[GTImageRequestBuilder buildGetGraffiti:annotation.item.graffitiId]]];
            request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            UIImage *i = [UIImage imageWithData:imageData];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                STTagThumbnail *thumbnail = [STTagThumbnail new];
                thumbnail.image = i;
                thumbnail.title = annotation.item.user.fullName;
                thumbnail.subtitle = annotation.item.user.mentionUsername;
                thumbnail.coordinate = CLLocationCoordinate2DMake(annotation.item.latitude, annotation.item.longitude);
                thumbnail.disclosureBlock = ^{
                    [ViewControllerUtils showTag:annotation.item fromViewController:weakSelf];
                };
                
                [annotation updateThumbnail:thumbnail animated:YES];
            });
        }
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length > 0)
        [self searchLocationForAddress:textField.text];
    
    return YES;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!showedFirstUserLocation && !self.location)
        [self centerToLocation:myMapView.userLocation.location];
    
    showedFirstUserLocation = YES;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)])
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)])
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)])
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    
    return nil;
}

#pragma mark - ADClusterMapView Delegate

- (MKAnnotationView *)mapView:(TSClusterMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation {
    
    TSDemoClusteredAnnotationView * view = (TSDemoClusteredAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([TSDemoClusteredAnnotationView class])];
    if (!view) {
        view = [[TSDemoClusteredAnnotationView alloc] initWithAnnotation:annotation
                                                         reuseIdentifier:NSStringFromClass([TSDemoClusteredAnnotationView class])];
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if( mapView.region.span.latitudeDelta > 11.0 || mapView.region.span.longitudeDelta > 11.0) {
        MKCoordinateRegion region = mapView.region;
        region.span = MKCoordinateSpanMake(10.0, 10.0);
        [mapView setRegion:region animated:YES];
    }
    else
        [self loadItems];
}

#pragma mark - Setup

- (void)setupMapView {
    myMapView.clusterDiscrimination = 1.0;
    myMapView.rotateEnabled = NO;
}

- (void)setupButtons {
    NSArray *views = @[backButton, searchView, segmentView];
    
    for (UIButton *b in views) {
        b.layer.cornerRadius = 5.0f;
        b.layer.masksToBounds = NO;
        b.layer.shadowColor = [UIColor blackColor].CGColor;
        b.layer.shadowOpacity = 0.5;
        b.layer.shadowRadius = 1;
        b.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    }
    
    [backButton setImage:[backButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    [searchButton setImage:[searchButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    [gridButton setImage:[gridButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
    [locateButton setImage:[locateButton.imageView.image imageWithTint:UIColorFromRGB(COLOR_MAIN)] forState:UIControlStateNormal];
}

@end
