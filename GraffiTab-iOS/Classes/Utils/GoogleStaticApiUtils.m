//
//  GoogleStaticApiUtils.m
//  EZtrans
//
//  Created by Georgi Christov on 2/3/14.
//  Copyright (c) 2014 Georgi Christov. All rights reserved.
//

#import "GoogleStaticApiUtils.h"

@implementation GoogleStaticApiUtils

+ (NSString *)getStaticMapUrlForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [[NSString stringWithFormat:@"%@center=%f,%f&zoom=16&size=600x300&maptype=roadmap&markers=color:blue|%f,%f&sensor=false", GOOGLE_URL_LOCATION_IMAGE, latitude, longitude, latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)getStaticStreetViewUrlForLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [[NSString stringWithFormat:@"%@size=600x300&location=%f,%f&sensor=false", GOOGLE_URL_STREET_VIEW_IMAGE, latitude, longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
