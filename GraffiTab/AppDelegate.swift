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
import CocoaLumberjack
import PAGestureAssistant
import CoreLocation

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Facebook-specific call.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in
            // Some code.
        }
        
        // Initialize the device motion manager.
        let _ = GTDeviceMotionManager.manager
        
        // Initialize the network connectivity manager.
        let _ = GTNetworkManager.manager
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogin(_:)), name:Notifications.UserLoggedIn, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.userDidLogout), name:Notifications.UserLoggedOut, object:nil)
        
        configureApp()
        
        setupGestureAssistant()
        
        Utils.runWithDelay(1) { () in
            self.checkOnboarding(launchOptions)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        GTLifecycleManager.applicationWillResignActive()
        
        // Configure location updates if location services is enabled.
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            GTLocationManager.manager.stopLocationUpdates()
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Application did enter background")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Facebook-specific call.
        FBSDKAppEvents.activateApp()
        
        GTLifecycleManager.applicationDidBecomeActive()
        
        // Configure location updates if location services is enabled.
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            GTLocationManager.manager.startLocationUpdates()
        }
        
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Application did enter foreground")
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
    
    // MARK: - Universal links
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        // 1. First, you verify that the passed-in userActivity has expected characteristics. Ultimately, you want to get the path component for the activity. Otherwise, you return false to indicate that the app can’t handle the activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true),
            let path = components.path else {
                return false
        }

        // 2. Using the path, check if it can be handled by the app.
        if path.localizedCaseInsensitiveContainsString("getstarted") { // The default action for this is to start the main app.
            return true
        }
        
        // 3. If no computer that matches the path is found, you instruct the application to open the URL, which will use the default system app instead—most likely Safari. You also return false here, to indicate that the app can’t handle the user activity.
        let webpageUrl = url
        application.openURL(webpageUrl)
        
        return false
    }
    
    // MARK: - Push notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Original token: \(deviceToken)")
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        Settings.sharedInstance.lastPushNotificationToken = deviceTokenStr
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Registering token: \(deviceTokenStr)")
        GTMeManager.linkDevice(deviceTokenStr, successBlock: { (response) in
            
        }) { (response) in
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DDLogError("[\(NSStringFromClass(self.dynamicType))] Failed to register device token for push notifications: \(error.description)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received push notification")
        
        // Send PN locally to entire app.
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.PushNotificationReceived, object: nil, userInfo: userInfo)
        
        // Process PN.
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
    
    func registerForNotifications() {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func reRegisterForNotifications() {
        if GTMeManager.sharedInstance.isLoggedIn() && Settings.sharedInstance.acceptedNotifications! {
            registerForNotifications()
        }
    }
    
    // MARK: - Login management
    
    func checkOnboarding(launchOptions: [NSObject: AnyObject]?) {
        if !Settings.sharedInstance.showedOnboarding! {
            let storyboard = UIStoryboard(name: "OnboardingStoryboard", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! OnboardingViewController
            vc.dismissHandler = {
                Settings.sharedInstance.showedOnboarding = true
                
                self.checkLoginStatus(launchOptions)
            }
            showViewController(vc, duration: 0.3)
        }
        else {
            checkLoginStatus(launchOptions)
        }
    }
    
    func checkLoginStatus(launchOptions: [NSObject: AnyObject]?) {
        if (GTMeManager.sharedInstance.isLoggedIn()) {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User logged in")
            
            let successHandler = {(refreshed: Bool) in
                if refreshed {
                    DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Profile refreshed")
                }
                else {
                    DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Connection not available. Opening main app.")
                }
                
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                
                self.userDidLogin(launchOptions)
            }
            
            let errorHandler = {
                DDLogError("[\(NSStringFromClass(self.dynamicType))] Failed to refresh profile")
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                
                self.userDidLogin(launchOptions)
            }
            
            if GTNetworkManager.manager.reach.isReachable() {
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Refreshing profile")
                GTMeManager.getMyFullProfile(successBlock: { (response) -> Void in
                    successHandler(true)
                }, failureBlock: { (response) -> Void in
                    errorHandler()
                })
            }
            else {
                successHandler(false)
            }
        }
        else {
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
            
            userDidLogout()
        }
    }
    
    func userDidLogin(launchOptions: [NSObject: AnyObject]?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User logged in. Showing main app")
        
        self.showStoryboard("MainStoryboard", duration: 0.3);
        
        // Request push notification token if PNs are enabled.
        reRegisterForNotifications()
        
        // Check if app has been started by clicking on a push notification.
        self.processPushNotificationInfo(launchOptions)
    }
    
    func userDidLogout() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User logged out. Showing login screen")
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.loginStatusBarStyle!, animated: true)
        
        GTMeManager.sharedInstance.logout()
        Settings.sharedInstance.resetPreferences()
        
        showStoryboard("LoginStoryboard", duration: 0.3);
    }
    
    // MARK: - Storyboard animations
    
    func showStoryboard(name: String, duration: Double) {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        
        showViewController(vc!, duration: duration)
    }
    
    func showViewController(controller: UIViewController, duration: Double) {
        UIView.transitionWithView(self.window!, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.window?.rootViewController = controller
        }, completion: {(finished) in
                
        })
    }
    
    // MARK: - Touch
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        // Delect status bar touches and dispatch it to the appropriate view controllers.
        // This is needed because the automatic scroll doesn't work if the table or collection views are not in the root of the view hierarchy.
        let events = event!.allTouches()
        let touch = events!.first
        let location = touch!.locationInView(self.window)
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        if CGRectContainsPoint(statusBarFrame, location) {
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.AppStatusBarTouched, object: nil)
        }
    }
    
    // MARK: - Setup
    
    func setupGestureAssistant() {
        PAGestureAssistant.appearance().tapImage = UIImage(named: "hand")
        PAGestureAssistant.appearance().backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        PAGestureAssistant.appearance().tapColor = AppConfig.sharedInstance.theme?.primaryColor
        PAGestureAssistant.appearance().textColor = AppConfig.sharedInstance.theme?.primaryColor
    }
    
    // MARK: - Configuration
    
    func configureApp() {
        AppConfig.sharedInstance.configureApp()
    }
}

