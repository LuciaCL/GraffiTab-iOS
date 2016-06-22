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
import Reachability
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var networkBanner: UILabel?
    
    var isAppStore: Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setupTestFramework()
        
        // Set the domain if we've previously selected one.
        if Settings.sharedInstance.appDomain != nil {
            GTSettings.sharedInstance.setAppDomain(Settings.sharedInstance.appDomain!)
        }
        
        // Facebook-specific call.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in
            // Some code.
        }
        
        // Clear app badge.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        // Initialize the location manager.
        let _ = GTLocationManager.manager
        
        // Initialize the device motion manager.
        let _ = GTDeviceMotionManager.manager
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogin(_:)), name:Notifications.UserLoggedIn, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogout), name:Notifications.UserLoggedOut, object:nil)
        
        setupTopBar()
        setupCache()
        setupRechability()
        setupLog()
        
        Utils.runWithDelay(1) { () in
            self.checkLoginStatus(launchOptions)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        GTLifecycleManager.applicationWillResignActive()
        GTLocationManager.manager.stopLocationUpdates()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application did enter background")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Facebook-specific call.
        FBSDKAppEvents.activateApp()
        
        GTLifecycleManager.applicationDidBecomeActive()
        GTLocationManager.manager.startLocationUpdates()
        
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application did enter foreground")
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
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Original token: \(deviceToken)")
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Registering token: \(deviceTokenStr)")
        GTMeManager.linkDevice(deviceTokenStr, successBlock: { (response) in
            
        }) { (response) in
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DDLogError("[\(NSStringFromClass(self.dynamicType))] Failed to register device token for push notifications: \(error.description)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Received push notification")
        
        if application.applicationState == .Active {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received push notification in Active state")
        }
        else { // This method is called when the app is in suspended state and the push notification is pressed.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received push notification in Background state")
            // Check if app has been started by clicking on a push notification.
            processPushNotificationInfo(userInfo)
        }
    }
    
    func convertDeviceTokenToString(deviceToken: NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "", options: [], range: nil)
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
        
        return deviceTokenStr
    }
    
    func processPushNotificationInfo(userInfo: [NSObject : AnyObject]?) {
        Utils.runWithDelay(1) {
            if userInfo != nil {
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Processing push notification")
                // TODO: Ignore tapping on notification for now.
            }
        }
    }
    
    // MARK: - Login management
    
    func checkLoginStatus(launchOptions: [NSObject: AnyObject]?) {
        if (GTSettings.sharedInstance.isLoggedIn()) {
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] User logged in. Refreshing profile")
            
            GTMeManager.getMyFullProfile({ (response) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                
                self.userDidLogin(launchOptions)
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
    
    func userDidLogin(launchOptions: [NSObject: AnyObject]?) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] User logged in. Showing main app")
        
        showStoryboard("MainStoryboard", duration: 0.3);
        
        registerPushNotifications()
        
        // Check if app has been started by clicking on a push notification.
        processPushNotificationInfo(launchOptions)
    }
    
    func userDidLogout() {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] User logged out. Showing login screen")
        
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
        let cacheSizeMemory = 50 * 1024 * 1024
        let cacheSizeDisk = 300 * 1024 * 1024
        let sharedCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
    }
    
    func setupRechability() {
        // Setup info label.
        self.networkBanner = UILabel(frame: CGRectMake(0, self.window!.bounds.height, self.window!.bounds.width, 27))
        self.networkBanner?.textColor = .whiteColor()
        self.networkBanner?.textAlignment = .Center
        self.networkBanner?.font = UIFont.systemFontOfSize(13)
        self.networkBanner?.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleTopMargin]
        self.networkBanner?.hidden = true
        self.window?.addSubview(self.networkBanner!)
        
        // Allocate a reachability object.
        let reach = Reachability(hostName: "www.google.com")
        
        // Set the blocks.
        reach.reachableBlock = { (reachability) in
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application has connectivity")
            
            // keep in mind this is called on a background thread
            // and if you are updating the UI it needs to happen
            // on the main thread, like this:
            
            dispatch_async(dispatch_get_main_queue(), {
                if !self.networkBanner!.hidden {
                    self.window?.bringSubviewToFront(self.networkBanner!)
                    self.networkBanner?.text = "Connected"
                    
                    UIView.animateWithDuration(0.3, animations: { 
                        self.networkBanner?.layer.backgroundColor = UIColor(hexString: Colors.Green)!.CGColor
                    }, completion: { (finished) in
                        if finished {
                            Utils.runWithDelay(2, block: {
                                UIView.animateWithDuration(0.3, animations: {
                                    var f = self.networkBanner?.frame
                                    f!.origin.y = self.window!.bounds.height
                                    self.networkBanner?.frame = f!
                                    
                                    f = self.window?.rootViewController?.view.frame
                                    f!.size.height = self.window!.bounds.height
                                    self.window?.rootViewController?.view.frame = f!
                                    self.window?.rootViewController?.view.setNeedsUpdateConstraints()
                                    self.window?.rootViewController?.view.layoutIfNeeded()
                                }, completion: { (finished) in
                                    if finished {
                                        self.networkBanner?.hidden = true
                                    }
                                })
                            })
                        }
                    })
                }
            });
        }
        reach.unreachableBlock = { (reachability) in
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application lost connectivity")
            
            dispatch_async(dispatch_get_main_queue(), {
                if self.networkBanner!.hidden {
                    self.window?.bringSubviewToFront(self.networkBanner!)
                    self.networkBanner?.hidden = false
                    self.networkBanner?.layer.backgroundColor = UIColor.blackColor().CGColor
                    self.networkBanner?.text = "No Internet connection"
                    
                    UIView.animateWithDuration(0.3, animations: { 
                        var f = self.networkBanner?.frame
                        f!.origin.y = self.window!.bounds.height - self.networkBanner!.frame.height
                        self.networkBanner?.frame = f!
                        
                        f = self.window?.rootViewController?.view.frame
                        f!.size.height = self.window!.bounds.height - self.networkBanner!.frame.height
                        self.window?.rootViewController?.view.frame = f!
                        self.window?.rootViewController?.view.setNeedsUpdateConstraints()
                        self.window?.rootViewController?.view.layoutIfNeeded()
                    })
                }
            });
        }
        
        // Start the notifier, which will cause the reachability object to retain itself!
        reach.startNotifier()
    }
    
    func setupTestFramework() {
        if !isAppStore {
            #if DEBUG
                
            #else
                DeployGateSDK.sharedInstance().launchApplicationWithAuthor("graffitab", key: "747b4f90cf1d7573866748c0f81f1b687fa77313")
                
//                TestFairy.begin("70be1b90ec3e2c91eefd4b0883691d0194ac5185")
//                TestFairy.setServerEndpoint("http://example.com")
            #endif
        }
    }
    
    func setupLog() {
        if !isAppStore { // We are deploying to dev or testing locally.
            #if DEBUG // Show full debug traces.
                GTLogManager.setupApplicationLogger(true, logToDeviceLogs: true, logToFile: true, level: .Debug)
            #else
                GTLogManager.setupApplicationLogger(false, logToDeviceLogs: false, logToFile: true, level: .Info)
                DDLog.addLogger(DeployGateLogger.sharedInstance)
            #endif
        }
        else { // Packaging for the App Store.
            // Show only errors.
            GTLogManager.setupApplicationLogger(false, logToDeviceLogs: false, logToFile: true, level: .Error)
        }
    }
}

