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

- (NSSet *)getRegions {
    return locationManager.monitoredRegions;
}

- (BOOL)canMonitorRegions {
    return [CLLocationManager isMonitoringAvailableForClass:[CLRegion class]];
}

- (void)startMonitoringRegion:(CLRegion *)region {
    region.notifyOnEntry = YES;
    region.notifyOnExit = NO;
    [locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringRegion:(CLRegion *)region {
    [locationManager stopMonitoringForRegion:region];
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
        [locationManager requestAlwaysAuthorization];
    
    self.lastLocation = locationManager.location;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        [Utils showMessage:APP_NAME message:@"You have entered one of your geographical regions. To explore it, navigate to the Graffiti Map."];
    else {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"You have entered one of your geographical regions. Explore it here."];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }
}

@end
