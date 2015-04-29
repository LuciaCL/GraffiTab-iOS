//
//  MyLocationManager.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "MyLocationManager.h"

@interface MyLocationManager () {
    
    CLLocationManager *locationManager;
}

@end

@implementation MyLocationManager

static MyLocationManager *instance = nil;

+ (MyLocationManager *)sharedInstance {
    if (!instance)
        instance = [MyLocationManager new];
    
    return instance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self baseInit];
    }
    
    return self;
}

- (void)startLocationUpdates {
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [locationManager stopUpdatingLocation];
}

- (void)baseInit {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (IS_IOS8_AND_UP)
        [locationManager requestWhenInUseAuthorization];
    
    self.lastLocation = locationManager.location;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastLocation = [locations lastObject];
}

@end
