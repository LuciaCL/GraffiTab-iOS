//
//  MapThumbnailsViewController.h
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 20/04/2015.
//  Copyright (c) 2015 GraffiTab. All rights reserved.
//

#import "STThumbnailOnlyViewController.h"

@interface MapThumbnailsViewController : STThumbnailOnlyViewController

@property (nonatomic, assign) CLLocationCoordinate2D neCoord;
@property (nonatomic, assign) CLLocationCoordinate2D swCoord;

@end
