//
//  GraffitiMapViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 19/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "BackButtonViewController.h"
#import "TSClusterMapView.h"

@interface GraffitiMapViewController : BackButtonViewController <TSClusterMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL isModal;

@end
