//
//  Utils.swift
//  MassAlert
//
//  Created by Georgi Christov on 14/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CocoaLumberjack

class Utils: NSObject {

    class func randomFloat(min: Double, max: Double) -> Double {
        let randomDouble = Double(arc4random()) / Double(UINT32_MAX)
        return (randomDouble * (max-min)) + min
    }
    
    class func logoutUserAndShowLoginController(controller: UIViewController) {
        DDLogInfo("[GraffiTab] Logout")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("logout", label: nil)
        
        controller.view.showActivityView()
        controller.view.rn_activityView.dimBackground = false
        
        // Show login screen.
        let loginScreenBlock = {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedOut, object: nil)
        }
        
        // Logout.
        let logoutBlock = {
            GTUserManager.logout({ (response) in
                controller.view.hideActivityView()
                
                loginScreenBlock()
            }) { (response) in
                controller.view.hideActivityView()
                
                loginScreenBlock()
            }
        }
        
        // Unregister this device token, if it exists.
        let unregisterDeviceBlock = {
            if Settings.sharedInstance.lastPushNotificationToken != nil {
                GTMeManager.unlinkDevice(Settings.sharedInstance.lastPushNotificationToken!, successBlock: { (response) in
                    logoutBlock()
                }, failureBlock: { (response) in
                    logoutBlock()
                })
            }
            else {
                logoutBlock()
            }
        }
        
        unregisterDeviceBlock()
    }
    
    class func applyShadowEffect(view: UIView, offset: CGSize, opacity: CGFloat, radius: CGFloat) {
        let shadowPath: CGPathRef = UIBezierPath(rect: view.bounds).CGPath
        let layer = view.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowPath = shadowPath
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
    
    class func shareImage(image: UIImage?, viewController: UIViewController, fromView: UIView) {
        if image != nil {
            let messageStr = "Check out my awesome drawing at GraffiTab!"
            let shareItems = [image!, messageStr]
            let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo]
            
            if DeviceType.IS_IPAD {
                activityViewController.modalPresentationStyle = .Popover
                activityViewController.popoverPresentationController?.sourceView = fromView
                activityViewController.popoverPresentationController?.sourceRect = fromView.bounds
            }
            
            viewController.presentViewController(activityViewController, animated: true, completion: nil)
        }
        else {
            DialogBuilder.showErrorAlert(viewController, status: NSLocalizedString("share_image", comment: ""), title: App.Title)
        }
    }
}
