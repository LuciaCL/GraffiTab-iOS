//
//  ViewControllerUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Photos

class ViewControllerUtils: NSObject {

    class func showUserProfile(user: GTUser, viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = user
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let nav = UINavigationController(rootViewController: vc)
            viewController.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    class func showComments(streamable: GTStreamable, viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        vc.streamable = streamable
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let nav = UINavigationController(rootViewController: vc)
            viewController.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    class func showLikers(streamable: GTStreamable, viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LikersViewController") as! LikersViewController
        vc.streamable = streamable
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show likers - Unknown parent.")
        }
    }
    
    class func showExplorer(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ExploreViewController") as! ExploreViewController
        vc.toShowLatitude = latitude
        vc.toShowLongitude = longitude
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let nav = UINavigationController(rootViewController: vc)
            viewController.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    class func checkCameraAndPhotosPermissions(successBlock: () -> Void) {
        // Check camera permission.
        let checkCameraPermission = {
            let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            switch status {
            case .Authorized:
                successBlock()
                break
            case .NotDetermined:
                successBlock()
                break
            case .Denied, .Restricted:
                successBlock()
                break
            }
        }
        
        // Check photos permission.
        PHPhotoLibrary.requestAuthorization { status in
            dispatch_async(dispatch_get_main_queue(),{
                switch status {
                case .Authorized:
                    checkCameraPermission()
                    break
                case .Restricted, .Denied:
                    checkCameraPermission()
                    break
                default:
                    checkCameraPermission()
                    break
                }
            })
        }
    }
}
