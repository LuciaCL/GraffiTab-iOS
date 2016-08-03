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
    
    func checkPermission(type: PermissionType, controller: UIViewController, accessGrantedHandler: (() -> Void)? = nil) {
        if type == .Notifications {
            checkNotificationsPermission(controller)
        }
        else if type == .Photos {
            checkPhotosPermission(controller, accessGrantedHandler: accessGrantedHandler)
        }
    }
    
    private func checkNotificationsPermission(controller: UIViewController) {
        let askForAccess = {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
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
    
    private func checkPhotosPermission(controller: UIViewController, accessGrantedHandler: (() -> Void)?) {
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
}
