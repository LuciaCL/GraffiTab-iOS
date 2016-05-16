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
}
