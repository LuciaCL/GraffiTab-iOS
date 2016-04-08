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
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.distanceFilter = kCLDistanceFilterNone
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager?.requestAlwaysAuthorization()
        
        lastLocation = locationManager?.location
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
}
