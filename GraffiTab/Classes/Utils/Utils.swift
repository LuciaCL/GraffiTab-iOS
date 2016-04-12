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
}
