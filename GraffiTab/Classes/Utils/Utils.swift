//
//  Utils.swift
//  MassAlert
//
//  Created by Georgi Christov on 14/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class Utils: NSObject {

    class func logoutUserAndShowLoginController() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedOut, object: nil)
    }
    
    class func applyShadowEffectToView(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSizeMake(1, 1)
        layer.shadowRadius = 2.0
        view.clipsToBounds = false
    }
    
    class func applyPublishShadowEffectToView(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSizeMake(1, 1)
        layer.shadowRadius = 2.0
        view.clipsToBounds = false
    }
    
    class func applyCanvasShadowEffectToView(view: UIView) {
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSizeMake(-2, -2)
        layer.shadowRadius = 2.0
        view.clipsToBounds = false
    }
    
    class func runWithDelay(sec: Double, block: (Void) -> Void) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(sec * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            block()
        }
    }
    
    class func openUrl(link: String) {
        var text = link
        var url = NSURL(string: text)
        
        if (url!.scheme.characters.count <= 0) {
            text = "http://" + text
            url = NSURL(string: text)
        }
        
        UIApplication.sharedApplication().openURL(url!)
    }
    
    class func showView(view: UIView) {
        UIView.animateWithDuration(0.3) { 
            view.alpha = 1
        }
    }
    
    class func hideView(view: UIView) {
        UIView.animateWithDuration(0.3) {
            view.alpha = 0
        }
    }
    
    class func shareImage(image: UIImage, viewController: UIViewController) {
        let messageStr = "Check out my awesome graffiti at GraffiTab!"
        let shareItems = [image, messageStr]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
        viewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
