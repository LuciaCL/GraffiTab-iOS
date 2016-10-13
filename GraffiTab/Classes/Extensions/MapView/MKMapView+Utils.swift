//
//  MKMapView+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/10/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {

    func calculateSpanDistance() -> Double {
        let mRect = self.visibleMapRect
        let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        
        return MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
    }
}
