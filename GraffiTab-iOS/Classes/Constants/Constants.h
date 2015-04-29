//
//  Constants.h
//  MyBabyPOC
//
//  Created by Georgi Christov on 10/18/13.
//  Copyright (c) 2013 GraffiTab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_NAME @"GraffiTab"

#define GOOGLE_URL_LOCATION_IMAGE @"http://maps.googleapis.com/maps/api/staticmap?"
#define GOOGLE_URL_STREET_VIEW_IMAGE @"http://maps.googleapis.com/maps/api/streetview?"
#define GOOGLE_URL_DIRECTIONS @"http://maps.googleapis.com/"

#define APP_FACEBOOK_AVATAR_URL @"https://graph.facebook.com/%@/picture?type=large"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define IS_LANDSCAPE ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define IS_IOS8_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define IS_IOS6_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
#define IS_IOS5_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0)

#define KEYBOARD_HEIGHT_IPHONE_P 216
#define KEYBOARD_HEIGHT_IPHONE_L 162
#define KEYBOARD_HEIGHT_IPAD_P 264
#define KEYBOARD_HEIGHT_IPAD_L 352
#define STATUSBAR_HEIGHT 20
#define NAVIGATIONBAR_HEIGHT 44
#define TOOLBAR_HEIGHT 40
#define TABBAR_HEIGHT 49

#define NOTIFICATION_LOG_IN @"NOTIFICATION_LOG_IN"
#define NOTIFICATION_LOG_OUT @"NOTIFICATION_LOG_OUT"
#define NOTIFICATION_UPDATE_UNSEEN_ITEMS @"NOTIFICATION_UPDATE_UNSEEN_ITEMS"
#define NOTIFICATION_UPDATE_LOCATIONS @"NOTIFICATION_UPDATE_LOCATIONS"

#define KEY_LOGGED_IN_USER @"KEY_LOGGED_IN_USER"
#define KEY_TIP_MENU @"KEY_TIP_MENU"
#define KEY_TOKEN @"KEY_TOKEN"
#define KEY_CACHE_USERNAMES @"KEY_CACHE_USERNAMES"
#define KEY_CACHE_HASHTAGS @"KEY_CACHE_HASHTAGS"

#define COLOR_AWESOME 0x3F739A
#define COLOR_LINKS 0xef6a0e
#define COLOR_MAIN 0x005c86
#define COLOR_ORANGE 0xe9a13a
#define COLOR_USERNAME 0x000000

#define MAX_ITEMS 18
#define COMPRESSION_QUALITY 0.7
