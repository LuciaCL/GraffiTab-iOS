//
//  CreateLocationViewController.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 11/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "CreateLocationViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface CreateLocationViewController () {
    
    IBOutlet UIImageView *mapCenterImage;
    IBOutlet MKMapView *mapView;
    
    BOOL showedLocation;
    CLPlacemark *lastPlacemark;
}

- (IBAction)onClickCenter:(id)sender;

@end

@implementation CreateLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTopBar];
    [self setupImageViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickCenter:(id)sender {
    [self centerToUserLocation];
}

- (void)onClickCreate {
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
                [self.navigationController popViewControllerAnimated:YES];
            });
        } failureBlock:^(GTResponseObject *response) {
            [[LoadingViewManager getInstance] removeLoadingView];
            
            if (response.reason == AUTHORIZATION_NEEDED) {
                [Utils logoutUserAndShowLoginController];
                [Utils showMessage:APP_NAME message:@"Your session has timed out. Please login again."];
            }
            else if (response.reason == DATABASE_ERROR || response.reason == NOT_FOUND || response.reason == NETWORK || response.reason == OTHER)
                [Utils showMessage:APP_NAME message:response.message];
        }];
    }
}

#pragma mark - MKMapViewDelegate

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
                           self.navigationItem.title = newString;
                       }
                   }];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!showedLocation)
        [self centerToUserLocation];
    
    showedLocation = YES;
}

- (void)centerToUserLocation {
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    
    [mapView setRegion:mapRegion animated: YES];
}

#pragma mark - Setup

- (void)setupTopBar {
    self.title = @"Create a Location";
    
    UIBarButtonItem *create = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(onClickCreate)];
    
    self.navigationItem.rightBarButtonItem = create;
}

- (void)setupImageViews {
    CGRect f = mapCenterImage.frame;
    f.origin.y = mapView.center.y - f.size.height / 2 + 10;
    mapCenterImage.frame = f;
}

@end
