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
        let vc = viewController.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = user
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show user profile - Unknown parent.")
        }
    }
    
    class func showComments(streamable: GTStreamable, viewController: UIViewController) {
        let vc = viewController.storyboard?.instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        vc.streamable = streamable
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show comments - Unknown parent.")
        }
    }
    
    class func showLikers(streamable: GTStreamable, viewController: UIViewController) {
        let vc = viewController.storyboard?.instantiateViewControllerWithIdentifier("LikersViewController") as! LikersViewController
        vc.streamable = streamable
        
        if viewController.navigationController != nil {
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show likers - Unknown parent.")
        }
    }
}
