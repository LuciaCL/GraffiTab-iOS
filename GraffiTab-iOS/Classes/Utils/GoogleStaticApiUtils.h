//
//  GoogleStaticApiUtils.h
//  EZtrans
//
//  Created by Georgi Christov on 2/3/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleStaticApiUtils : NSObject

+ (NSString *)getStaticMapUrlForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (NSString *)getStaticStreetViewUrlForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

@end
