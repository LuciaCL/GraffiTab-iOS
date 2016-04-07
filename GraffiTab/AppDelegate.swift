//
//  AppDelegate.swift
//  GraffiTab
//
//  Created by Georgi Christov on 04/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftHEXColors
import GraffiTab_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        TestFairy.begin("d32aea7783e618827035d36925eba3ff505a7542")
        
        // Facebook-specific call.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in
            // Some code.
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogin), name:Notifications.UserLoggedIn, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogout), name:Notifications.UserLoggedOut, object:nil)
        
        setupTopBar()
        setupCache()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.checkLoginStatus()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        GTLifecycleManager.applicationWillResignActive()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Facebook-specific call.
        FBSDKAppEvents.activateApp()
        
        GTLifecycleManager.applicationDidBecomeActive()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Facebook
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // Even though the Facebook SDK can make this determinitaion on its own,
        // let's make sure that the facebook SDK only sees urls intended for it,
        // facebook has enough info already!
        let isFacebookURL = url.scheme.hasPrefix("fb\(FBSDKSettings.appID())") && url.host == "authorize"
        if isFacebookURL {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return false
    }
    
    // MARK: - Push notifications
    
    func registerPushNotifications() {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("DEBUG: Original token: \(deviceToken)")
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        print("DEBUG: Registering token: \(deviceTokenStr)")
        GTUserManager.linkDevice(deviceTokenStr, successBlock: { (response) in
            
        }) { (response) in
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("DEBUG: Device token for push notifications: FAIL -- ")
        print(error.description)
    }
    
    func convertDeviceTokenToString(deviceToken: NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        
        return deviceTokenStr
    }
    
    // MARK: - Login management
    
    func checkLoginStatus() {
        if (GTSettings.sharedInstance.isLoggedIn()) {
            GTUserManager.getMe({ (response) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                
                self.userDidLogin()
            }, failureBlock: { (response) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                
                self.userDidLogout()
            })
        }
        else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
            
            userDidLogout()
        }
    }
    
    func userDidLogin() {
        showStoryboard("MainStoryboard", duration: 0.3);
        
        registerPushNotifications()
    }
    
    func userDidLogout() {
        GTSettings.sharedInstance.logout()
        
        showStoryboard("LoginStoryboard", duration: 0.3);
    }
    
    // MARK: - Storyboard animations
    
    func showStoryboard(name: String, duration: Double) {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        
        UIView.transitionWithView(self.window!, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.window?.rootViewController = vc
            }, completion: nil)
    }
    
    // MARK: - Setup
    
    func setupTopBar() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        UINavigationBar.appearance().barTintColor = UIColor(hexString: Colors.Main)
        UINavigationBar.appearance().tintColor = UIColor(hexString: Colors.TitleTint)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hexString: Colors.TitleTint)!]
    }
    
    func setupCache() {
        let cacheSizeMemory = 20 * 1024 * 1024
        let cacheSizeDisk = 100 * 1024 * 1024
        let sharedCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
    }
}

