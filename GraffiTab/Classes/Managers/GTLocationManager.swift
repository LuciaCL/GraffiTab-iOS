//
//  GTLocationManager.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CoreLocation

class GTLocationManager: NSObject, CLLocationManagerDelegate {

    static var manager: GTLocationManager = GTLocationManager()
    
    var lastLocation: CLLocation?
    var locationManager: CLLocationManager?
    
    var accessGrantedHandler: (() -> Void)?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.distanceFilter = kCLDistanceFilterNone
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        lastLocation = locationManager?.location
    }
    
    // MARK: - Permissions
    
    func askPermissionWhenInUse(controller: UIViewController, accessGrantedHandler: (() -> Void)?) {
        self.accessGrantedHandler = accessGrantedHandler
        
        // If we haven't granted permission yet.
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways && CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager?.requestWhenInUseAuthorization()
            }
            else {
                DialogBuilder.showOKAlert(controller, status: NSLocalizedString("manager_location_permission", comment: ""), title: App.Title)
            }
        }
        else {
            self.accessGrantedHandler!()
        }
    }
    
    // MARK: - Location
    
    func startLocationUpdates() {
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if UIApplication.sharedApplication().applicationState == .Active {
            
        }
        else {
            let notification = UILocalNotification()
            notification.alertBody = NSLocalizedString("manager_location_permission_geofencing", comment: "")
            notification.fireDate = NSDate(timeIntervalSinceNow: 1)
            notification.timeZone = NSTimeZone.defaultTimeZone()
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            Settings.sharedInstance.promptedForLocationInUse = true // We have access so no need to further ask the user.
            
            if accessGrantedHandler != nil {
                accessGrantedHandler!()
            }
        }
    }
}
