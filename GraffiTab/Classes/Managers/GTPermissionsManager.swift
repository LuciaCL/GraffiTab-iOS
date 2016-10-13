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
    }
    
    private func checkNotificationsPermission(controller: UIViewController) {
        let askForAccess = {
            (UIApplication.sharedApplication().delegate as! AppDelegate).registerForNotifications()
        }
        
        if !Settings.sharedInstance.promptedForNotifications! {
            let permissionDialog = AskPermissionViewController.showPermissionViewController(controller, askPermissionHandler: {
                Settings.sharedInstance.promptedForNotifications = true
                Settings.sharedInstance.acceptedNotifications = true
                askForAccess()
            }, decideLaterHandler: {
                    
            })
            
            permissionDialog.permissionTitle.text = NSLocalizedString("manager_permission_notifications_title", comment: "")
            permissionDialog.permissionDescription.text = NSLocalizedString("manager_permission_notifications_description", comment: "")
            permissionDialog.permissionPreview.image = UIImage(named: "permission_notifications")
            permissionDialog.askBtn.setTitle(NSLocalizedString("manager_permission_notifications_button", comment: ""), forState: .Normal)
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
                            DialogBuilder.showOKAlert(controller, status: NSLocalizedString("manager_permission_photos_denied", comment: ""), title: App.Title)
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
            
            permissionDialog.permissionTitle.text = NSLocalizedString("manager_permission_photos_title", comment: "")
            permissionDialog.permissionDescription.text = NSLocalizedString("manager_permission_photos_description", comment: "")
            permissionDialog.permissionPreview.image = UIImage(named: "permission_photos")
            permissionDialog.askBtn.setTitle(NSLocalizedString("manager_permission_photos_button", comment: ""), forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
    
    private func checkLocationWhenInUse(controller: UIViewController, accessGrantedHandler: (() -> Void)?, decideLaterHandler: (() -> Void)?) {
        let askForAccess = {
            GTLocationManager.manager.askPermissionWhenInUse(controller, accessGrantedHandler: accessGrantedHandler)
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
    
            permissionDialog.permissionTitle.text = NSLocalizedString("manager_permission_location_title", comment: "")
            permissionDialog.permissionDescription.text = NSLocalizedString("manager_permission_location_description", comment: "")
            permissionDialog.permissionPreview.image = UIImage(named: "permission_location_when_in_use")
            permissionDialog.askBtn.setTitle(NSLocalizedString("manager_permission_location_button", comment: ""), forState: .Normal)
        }
        else {
            askForAccess()
        }
    }
}
