//
//  CreateLocationViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "CreateLocationViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "BlockActionSheet.h"

@interface CreateLocationViewController () {
    
    IBOutlet UIImageView *mapCenterImage;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *gridButton;
    IBOutlet UIButton *locateButton;
    IBOutlet UIView *segmentView;
    IBOutlet UIView *searchView;
    IBOutlet UITextField *searchField;
    
    BOOL showedFirstUserLocation;
    BOOL isSearching;
    CLPlacemark *lastPlacemark;
}

- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickSearch:(id)sender;
- (IBAction)onClickCreate:(id)sender;
- (IBAction)onClickLocate:(id)sender;

@end

@implementation CreateLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupButtons];
    [self setupImageViews];
    [self setupMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
    
    switch (mapView.mapType) {
        case MKMapTypeHybrid:
            mapView.mapType = MKMapTypeStandard;
            break;
        case MKMapTypeStandard:
            mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
    
    mapView.showsUserLocation = NO;
    mapView.delegate = nil;
    [mapView removeFromSuperview];
    mapView = nil;
}

- (IBAction)onClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)onClickCreate:(id)sender {
    if (!lastPlacemark)
        [Utils showMessage:APP_NAME message:@"Please select a location first."];
    else {
        [[LoadingViewManager getInstance] addLoadingToView:self.view withMessage:@"Processing..."];
        
        [GTLocationManager createLocationWithPlacemark:lastPlacemark successBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            [Utils showMessage:APP_NAME message:@"Your location was created successfully."];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_LOCATIONS object:nil];
            
            // Delay execution of my block for 10 seconds.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self onClickBack:nil];
            });
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == FORBIDDEN)
                [Utils showMessage:APP_NAME message:@"You have reached the maximum number of locations."];
            else
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
}

- (IBAction)onClickLocate:(id)sender {
    [self centerToLocation:mapView.userLocation.location];
}

- (void)centerToLocation:(CLLocation *)location {
    [self zoomMapToLocation:location];
}

#pragma mark - Searching

- (void)searchLocationForAddress:(NSString *)address {
    [[LoadingViewManager getInstance] addLoadingToView:self.view withMessage:@"Processing..."];
    
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
    
    [mapView setRegion:mapRegion animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length > 0)
        [self searchLocationForAddress:textField.text];
    
    return YES;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!showedFirstUserLocation)
        [self centerToLocation:mapView.userLocation.location];
    
    showedFirstUserLocation = YES;
}

- (void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude]
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0) {
                           lastPlacemark = [placemarks objectAtIndex:0];
                           
                           NSString *addressTxt = ABCreateStringWithAddressDictionary(lastPlacemark.addressDictionary, NO);
                           NSString *newString = [[addressTxt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@", "];
                           searchField.text = newString;
                       }
                   }];
}

- (void)centerToUserLocation {
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [mapView setRegion:mapRegion animated: YES];
}

#pragma mark - Setup

- (void)setupMapView {
    mapView.rotateEnabled = NO;
}

- (void)setupImageViews {
    CGRect f = mapCenterImage.frame;
    f.origin.y = mapView.center.y - f.size.height / 2 - 10;
    mapCenterImage.frame = f;
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
