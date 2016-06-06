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
import DGActivityIndicatorView
import CocoaLumberjack

class NearMeViewController: GridStreamablesViewController {
    
    @IBOutlet weak var locationLoadingContainer: UIView!
    @IBOutlet weak var locatingLbl: UILabel!
    
    var locationTimer: NSTimer?
    var locationLoadingIndicator: DGActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingView()
        
        hideLocationLoading()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLoadingView()
        
        locationLoadingIndicator?.startAnimating()
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        let location = GTLocationManager.manager.lastLocation

        if location != nil {
            hideLocationLoading()
            
            let center = location!.coordinate
            
            // Search for items within 1km radius of the user's current location.
            let region = MKCoordinateRegionMakeWithDistance(center, App.Radius, App.Radius)
            
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
            showLocationLoading()
            
            locationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.checkLocationFound), userInfo: nil, repeats: true)
        }
    }
    
    func checkLocationFound() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] No previous location detected. Attempting to locate")
        
        let location = GTLocationManager.manager.lastLocation
        
        if location != nil {
            locationTimer?.invalidate()
            locationTimer = nil
            
            refresh()
        }
    }
    
    func showLocationLoading() {
        self.locationLoadingIndicator!.startAnimating()
        
        UIView.animateWithDuration(0.3) {
            self.locationLoadingContainer?.alpha = 1
            self.locatingLbl.alpha = 1
            self.collectionView.alpha = 0
            self.pullToRefresh.alpha = 0
        }
    }
    
    func hideLocationLoading() {
        self.locationLoadingIndicator!.stopAnimating()
        
        UIView.animateWithDuration(0.3) { 
            self.locationLoadingContainer?.alpha = 0
            self.locatingLbl.alpha = 0
            self.collectionView.alpha = 1
            self.pullToRefresh.alpha = 1
        }
    }
    
    // MARK: - Setup
    
    func setupLoadingView() {
        if locationLoadingIndicator != nil {
            locationLoadingIndicator?.removeFromSuperview()
            locationLoadingIndicator = nil
        }
        
        locationLoadingIndicator = DGActivityIndicatorView(type: .BallBeat, tintColor: UIColor.lightGrayColor())
        locationLoadingIndicator?.frame = locationLoadingContainer.bounds
        locationLoadingContainer.addSubview(locationLoadingIndicator!)
    }
}
