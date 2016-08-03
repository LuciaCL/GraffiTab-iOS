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
    
    func askPermissionWhenInUse(accessGrantedHandler: (() -> Void)?) {
        self.accessGrantedHandler = accessGrantedHandler
        
        // If we haven't granted permission yet.
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways && CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager?.requestWhenInUseAuthorization()
            }
            else {
                DialogBuilder.showOKAlert("You will have to enable Location Services for GraffiTab in Settings before continuing with this action.", title: App.Title)
            }
        }
        else {
            self.accessGrantedHandler!()
        }
    }
    
    func askPermissionAlways(accessGrantedHandler: (() -> Void)?) {
        self.accessGrantedHandler = accessGrantedHandler
        
        // If we haven't granted permission yet.
        if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
            if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
                locationManager?.requestAlwaysAuthorization()
            }
            else {
                DialogBuilder.showYesNoAlert("You will have to enable Location Services for GraffiTab in Settings before continuing with this action.", title: App.Title, yesTitle: "Open Location Settings", noTitle: "No, thanks", yesAction: { 
                    // Send the user to the Settings for this app.
                    Utils.openUrl(UIApplicationOpenSettingsURLString)
                }, noAction: { 
                    
                })
            }
        }
        else {
            self.accessGrantedHandler!()
        }
    }
    
    // MARK: - Regions
    
    func getRegions() -> Set<CLRegion> {
        return (locationManager?.monitoredRegions)!
    }
    
    func canMonitorRegions() -> Bool {
        return CLLocationManager.isMonitoringAvailableForClass(CLRegion.classForCoder())
    }
    
    func startMonitoringRegion(region: CLRegion) {
        region.notifyOnEntry = true
        region.notifyOnExit = false
        locationManager?.startMonitoringForRegion(region)
    }
    
    func stopMonitoringRegion(region: CLRegion) {
        locationManager?.stopMonitoringForRegion(region)
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
            DialogBuilder.showOKAlert("You have entered one of your geographical regions. To explore it, navigate to the Explorer.", title: App.Title)
        }
        else {
            let notification = UILocalNotification()
            notification.alertBody = "You have entered one of your geographical regions. Explore it here."
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
