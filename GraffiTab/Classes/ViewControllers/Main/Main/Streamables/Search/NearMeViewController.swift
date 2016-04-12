//
//  NearMeViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import MapKit

class NearMeViewController: GridStreamablesViewController {
    
    // MARK: - ViewType-specific helpers
    
    override func getNumCols() -> Int {
        return 3
    }
    
    override func getSpacing() -> Int {
        return 2
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        let location = GTLocationManager.manager.lastLocation
        
        if location != nil {
            let center = location!.coordinate
            
            // Search for items within 1km radius of the user's current location.
            let region = MKCoordinateRegionMakeWithDistance(center, 1000.0, 1000.0)
            
            // Obtain bounding box GPS coordinates.
            var northEastCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
            northEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0)
            northEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0)
            
            var southWestCorner: CLLocationCoordinate2D = CLLocationCoordinate2D()
            southWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0)
            southWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0)
            
            GTStreamableManager.searchForLocation(northEastCorner.latitude, neLongitude: northEastCorner.longitude, swLatitude: southWestCorner.latitude, swLongitude: southWestCorner.longitude, successBlock: successBlock, failureBlock: failureBlock)
        }
        else {
            print("DEBUG: No previous location detected. Attempting to locate..")
        }
    }
}
