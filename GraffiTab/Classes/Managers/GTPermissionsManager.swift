//
//  GTPermissionsManager.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Photos

enum PermissionType {
    case Notifications
    case LocationWhenInUse
    case LocationAlways
    case Photos
}

class GTPermissionsManager: NSObject {

    static var manager: GTPermissionsManager = GTPermissionsManager()
    
    func checkPermission(type: PermissionType, controller: UIViewController, accessGrantedHandler: (() -> Void)? = nil, decideLaterHandler: (() -> Void)? = nil) {
        if type == .Notifications {
            checkNotificationsPermission(controller)
        }
        else if type == .Photos {
            checkPhotosPermission(controller, accessGrantedHandler: accessGrantedHandler, decideLaterHandler: decideLaterHandler)
        }
        else if type == .LocationWhenInUse {
            checkLocationWhenInUse(controller, accessGrantedHandler: accessGrantedHandler, decideLaterHandler: decideLaterHandler)
        }
        else if type == .LocationAlways {
            checkLocationAlways(controller, accessGrantedHandler: accessGrantedHandler, decideLaterHandler: decideLaterHandler)
        }
    }
    
    private func checkNotificationsPermission(controller: UIViewController) {
        let askForAccess = {
            (UIApplication.sharedApplication().delegate as! AppDelegate).registerForNotifications()
        }
        
        if !Settings.sharedInstance.promptedForNotifications! {
            let permissionDialog = AskPermissionViewController.showPermissionViewController(controller, askPermissionHandler: {
                Settings.sharedInstance.promptedForNotifications = true
                askForAccess()
            }, decideLaterHandler: {
                    
            })
            
            permissionDialog.permissionTitle.text = "Receive Notifications"
            permissionDialog.permissionDescription.text = "Staying connected with the people you follow is easier with push notifications.\n\nOtherwise you'll have to manually check the app for updates."
            permissionDialog.permissionPreview.image = UIImage(named: "permission_notifications")
            permissionDialog.askBtn.setTitle("Use Push Notifications", forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
    
    private func checkPhotosPermission(controller: UIViewController, accessGrantedHandler: (() -> Void)?, decideLaterHandler: (() -> Void)?) {
        let askForAccess = {
            PHPhotoLibrary.requestAuthorization { status in
                dispatch_async(dispatch_get_main_queue(),{
                    switch status {
                        case .Authorized:
                            if accessGrantedHandler != nil {
                                accessGrantedHandler!()
                            }
                            break
                        case .Restricted, .Denied:
                            DialogBuilder.showOKAlert("We need your permission to access the photos library. Please enable this in Settings", title: App.Title)
                            break
                        default:
                            // place for .NotDetermined - in this callback status is already determined so should never get here
                            break
                    }
                })
            }
        }
        
        if !Settings.sharedInstance.promptedForPhotos! {
            let permissionDialog = AskPermissionViewController.showPermissionViewController(controller, askPermissionHandler: {
                Settings.sharedInstance.promptedForPhotos = true
                askForAccess()
            }, decideLaterHandler: {
                if decideLaterHandler != nil {
                    decideLaterHandler!()
                }
            })
            
            permissionDialog.permissionTitle.text = "Background Pictures"
            permissionDialog.permissionDescription.text = "Want to set a background picture and draw on top of it? Awesome! We will just ask for your permission to pick photos from your library.\n\nPhotos will never be posted without your consent."
            permissionDialog.permissionPreview.image = UIImage(named: "permission_photos")
            permissionDialog.askBtn.setTitle("Use Background Pictures", forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
    
    private func checkLocationWhenInUse(controller: UIViewController, accessGrantedHandler: (() -> Void)?, decideLaterHandler: (() -> Void)?) {
        let askForAccess = {
            GTLocationManager.manager.askPermissionWhenInUse(accessGrantedHandler)
        }
        
        if !Settings.sharedInstance.promptedForLocationInUse! {
            let permissionDialog = AskPermissionViewController.showPermissionViewController(controller, askPermissionHandler: {
                Settings.sharedInstance.promptedForLocationInUse = true
                askForAccess()
            }, decideLaterHandler: {
                if decideLaterHandler != nil {
                    decideLaterHandler!()
                }
            })
    
            permissionDialog.permissionTitle.text = "Location Services"
            permissionDialog.permissionDescription.text = "In order to use the Explorer or create graffiti, we need to know where you are in the world.\n\nDon't worry, you can still do all those things but your artwork will be hidden on the map."
            permissionDialog.permissionPreview.image = UIImage(named: "permission_location_when_in_use")
            permissionDialog.askBtn.setTitle("Use Location Services", forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
    
    private func checkLocationAlways(controller: UIViewController, accessGrantedHandler: (() -> Void)?, decideLaterHandler: (() -> Void)?) {
        let askForAccess = {
            GTLocationManager.manager.askPermissionAlways(accessGrantedHandler)
        }
        
        if !Settings.sharedInstance.promptedForLocationAlways! {
            let permissionDialog = AskPermissionViewController.showPermissionViewController(controller, askPermissionHandler: {
                Settings.sharedInstance.promptedForLocationAlways = true
                askForAccess()
            }, decideLaterHandler: {
                if decideLaterHandler != nil {
                    decideLaterHandler!()
                }
            })
            
            permissionDialog.permissionTitle.text = "Location Tracking Services"
            permissionDialog.permissionDescription.text = "By tracking a location you will receive notifications when someone creates graffiti in that area or when you visit it.\n\nOtherwise you will have to check manually in the Explorer."
            permissionDialog.permissionPreview.image = UIImage(named: "permission_location_always")
            permissionDialog.askBtn.setTitle("Use Tracking Services", forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
}
