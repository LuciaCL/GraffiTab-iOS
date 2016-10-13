//
//  AppConfig.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Instabug
import CocoaLumberjack

class AppConfig: NSObject {

    static var sharedInstance: AppConfig = AppConfig()
    
    var customLanguages = [
        "bg-BG" : "Български"
    ]
    
    var isAppStore: Bool = false
    var useAnalytics: Bool = true
    var maxUndoActions = 10
    var onboardingFeedbackDaysTrigger = 2
    
    var locationRadius = 100 * 1000 // Distance in meters.
    var locationTimeout = 10 // Waiting time for location to become available for publishing.
    var mapInitialSpanDistance: Double = 1 * 1000 // Distance in meters.
    var mapMaxSpanDistance: Double = 3000 * 1000 // Distance in meters.
    var mapRefreshRate: Double = 3
    
    var logEnabled = true
    var httpsEnabled = true
//    var customUrl: String?
    var customUrl: String? = "dev.graffitab.com"
//    var customUrl: String? = "localhost:8091"
    
    var theme: GTTheme?
    
    func configureApp() {
        configureTestFramework()
        configureTheme(GTLightTheme())
        configureCache()
        configureSDK()
        configureAnalytics()
        configureInstabug()
    }
    
    // MARK: - Themes
    
    private func configureTheme(theme: GTTheme) {
        self.theme = theme
        
        UINavigationBar.appearance().barTintColor = theme.navigationBarBackgroundColor
        UINavigationBar.appearance().tintColor = theme.navigationBarElementsColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : theme.navigationBarElementsColor!]
    }
    
    // MARK: - GraffiTab SDK
    
    private func configureSDK() {
        let config = GTConfig.defaultConfig
        
        config.logEnabled = logEnabled
        config.httpsEnabled = httpsEnabled
        
        config.language = currentLanguage() // Set language to whatever is the chosen device language.
        
        if customUrl != nil {
            config.domain = customUrl
        }
        
        if !isAppStore { // We are deploying to dev or testing locally.
            #if DEBUG // Show full debug traces.
                config.logLevel = .Debug
            #else
                config.logLevel = .Info
                DDLog.addLogger(DeployGateLogger.sharedInstance)
            #endif
        }
        else { // Packaging for the App Store.
            // Show only errors.
            config.logLevel = .Error
        }
        
        GTSDKConfig.sharedInstance.setConfiguration(config)
    }
    
    // MARK: - App cache
    
    private func configureCache() {
        let cacheSizeMemory = 50 * 1024 * 1024
        let cacheSizeDisk = 300 * 1024 * 1024
        let sharedCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
    }
    
    // MARK: - DeployGate
    
    private func configureTestFramework() {
        if !AppConfig.sharedInstance.isAppStore {
            #if DEBUG
                
            #else
                DeployGateSDK.sharedInstance().launchApplicationWithAuthor("graffitab", key: "747b4f90cf1d7573866748c0f81f1b687fa77313")
            #endif
        }
    }
    
    // MARK: - Google Analytics
    
    private func configureAnalytics() {
        // No need to setup analytics here.
        if AppConfig.sharedInstance.useAnalytics {
            // Configure tracker from GoogleService-Info.plist.
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            
            // Optional: configure GAI options.
            let gai = GAI.sharedInstance()
            gai.trackUncaughtExceptions = true  // report uncaught exceptions
            
            if AppConfig.sharedInstance.isAppStore {
                gai.logger.logLevel = GAILogLevel.Info
            }
            else {
                gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
            }
        }
    }
    
    // MARK: - Instabug
    
    private func configureInstabug() {
        Instabug.startWithToken("95a2ae49aceb3d7c2b0d32c573a6231f", invocationEvent: IBGInvocationEvent.Shake)
        Instabug.setIntroMessageEnabled(false)
    }
    
    // MARK: - Language
    
    func updateSDKLanguage() {
        let config = GTSDKConfig.sharedInstance.getConfiguration()
        config.language = currentLanguage() // Set language to whatever is the chosen device language.
    }
    
    private func currentLanguage() -> String {
        var currentLanguage = Settings.sharedInstance.language == nil ? NSLocale.preferredLanguages().first! : Settings.sharedInstance.language!
        if currentLanguage.containsString("-") { // Parse language in the form en-UK
            let range = currentLanguage.rangeOfString("-", options: .BackwardsSearch)
            currentLanguage = currentLanguage.substringToIndex(range!.startIndex)
        }
        
        return currentLanguage
    }
}
