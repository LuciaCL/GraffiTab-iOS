//
//  ViewControllerUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

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
    
    class func showExplorer(latitude: CLLocationDegrees? = nil, longitude: CLLocationDegrees? = nil, user: GTUser? = nil, viewController: UIViewController) {
        let handler = {
            let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ExploreViewController") as! ExploreViewController
            vc.toShowLatitude = latitude
            vc.toShowLongitude = longitude
            vc.toShowUser = user
            
            if viewController.navigationController != nil {
                viewController.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let nav = UINavigationController(rootViewController: vc)
                viewController.presentViewController(nav, animated: true, completion: nil)
            }
        }
        
        GTPermissionsManager.manager.checkPermission(.LocationWhenInUse, controller: viewController, accessGrantedHandler: {
            handler()
        }) {
            handler()
        }
    }
    
    class func showStaticStreamables(streamables: [GTStreamable], viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StaticStreamablesViewController") as! StaticStreamablesViewController
        vc.items = streamables
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show static streamables - Unknown parent.")
        }
    }
    
    class func showStaticUsers(users: [GTUser], viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StaticUsersViewController") as! StaticUsersViewController
        vc.items = users
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show static users - Unknown parent.")
        }
    }
    
    class func showStreamableDetails(streamable: GTStreamable, modalPresentationStyle: UIModalPresentationStyle?, transitioningDelegate: UIViewControllerTransitioningDelegate?, viewController: UIViewController) {
        let vc = UIStoryboard(name: "MainStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("StreamableDetailViewController") as! StreamableDetailViewController
        vc.streamable = streamable
        
        if modalPresentationStyle != nil {
            vc.modalPresentationStyle = modalPresentationStyle!
        }
        if transitioningDelegate != nil {
            vc.transitioningDelegate = transitioningDelegate
        }
        
        viewController.presentViewController(vc, animated: true, completion: nil)
    }
}
