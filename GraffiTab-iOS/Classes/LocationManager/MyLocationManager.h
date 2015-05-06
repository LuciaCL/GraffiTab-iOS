//
//  MyLocationManager.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 05/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MyLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation *lastLocation;

+ (MyLocationManager *)sharedInstance;

- (NSSet *)getRegions;
- (BOOL)canMonitorRegions;
- (void)startMonitoringRegion:(CLRegion *)region;
- (void)stopMonitoringRegion:(CLRegion *)region;

- (void)startLocationUpdates;
- (void)stopLocationUpdates;

@end
