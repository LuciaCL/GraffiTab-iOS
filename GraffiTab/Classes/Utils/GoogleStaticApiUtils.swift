//
//  GoogleStaticApiUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 23/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

struct Google {
    static let StaticMap = "http://maps.googleapis.com/maps/api/staticmap?"
    static let StreetView = "http://maps.googleapis.com/maps/api/streetview?"
    static let Directions = "http://maps.googleapis.com/"
}

class GoogleStaticApiUtils: NSObject {

    class func getStaticMapUrl(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
        return String(format: "%@center=%f,%f&zoom=16&size=600x300&maptype=roadmap&markers=color:blue|%f,%f&sensor=false", Google.StaticMap, latitude, longitude, latitude, longitude).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    class func getStaticStreetViewUrl(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
        return String(format: "%@size=600x300&location=%f,%f&sensor=false", Google.StreetView, latitude, longitude).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
}
