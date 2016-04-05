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
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        clearCookies()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedOut, object: nil)
    }
    
    class func clearCookies() {
        for cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies! {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
        
        GTLifecycleManager.applicationWillResignActive()
    }
}
