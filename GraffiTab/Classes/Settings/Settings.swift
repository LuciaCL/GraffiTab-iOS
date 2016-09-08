//
//  Settings.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import KeychainAccess

class Settings: NSObject {

    static let sharedInstance = Settings()
    
    // App properties.
    
    var language: String? {
        get {
            return getStringPreference(SettingsKeys.kAppLanguage)
        }
        set(newValue) {
            setObjectPreference(newValue, key: SettingsKeys.kAppLanguage)
        }
    }
    
    var rememberCredentials: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kRememberCredentials)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kRememberCredentials)
        }
    }
    
    var showedDrawingAssistant: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kDrawingAssistant)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kDrawingAssistant)
        }
    }
    
    var showedOnboarding: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kOnboarding)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kOnboarding)
        }
    }
    
    var showedFeedbackOnboarding: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kFeedbackOnboarding)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kFeedbackOnboarding)
        }
    }
    
    var promptedForAvatar: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kPromptedForAvatar)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kPromptedForAvatar)
        }
    }
    
    var promptedForNotifications: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kPromptedForNotifications)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kPromptedForNotifications)
        }
    }
    
    var acceptedNotifications: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kAcceptedNotifications)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kAcceptedNotifications)
        }
    }
    
    var promptedForPhotos: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kPromptedForPhotos)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kPromptedForPhotos)
        }
    }
    
    var promptedForLocationInUse: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kPromptedForLocationInUse)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kPromptedForLocationInUse)
        }
    }
    
    var promptedForLocationAlways: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kPromptedForLocationAlways)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kPromptedForLocationAlways)
        }
    }
    
    // Keychain.
    
    var username: String? {
        get {
            return keychain[SettingsKeys.kUsername]
        }
        set(newValue) {
            keychain[SettingsKeys.kUsername] = newValue
        }
    }
    var password: String? {
        get {
            return keychain[SettingsKeys.kPassword]
        }
        set(newValue) {
            keychain[SettingsKeys.kPassword] = newValue
        }
    }
    
    var keychain = Keychain()
    
    override init() {
        super.init()
        
        basicInit()
    }
    
    func basicInit() {
        
    }
    
    func resetPreferences() {
        self.promptedForAvatar = false
    }
    
    func shouldShowFeedbackOnboarding() -> Bool {
        if getObjectPreference(SettingsKeys.kFirstStartDate) == nil {
            setObjectPreference(NSDate(), key: SettingsKeys.kFirstStartDate)
        }
        
        let firstStartDate = getObjectPreference(SettingsKeys.kFirstStartDate) as! NSDate
        let now = NSDate()
        let daysBetween = DateUtils.daysBetweenDates(firstStartDate, endDate: now)
        return daysBetween >= AppConfig.sharedInstance.onboardingFeedbackDaysTrigger
    }
    
    // MARK: - Languages
    
    func setupLanguage() {
        NSBundle.language = self.language
    }
    
    // MARK: - Helper functions
    
    func getObjectPreference(key: String) -> AnyObject? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.objectForKey(key)
    }
    
    func setObjectPreference(value: AnyObject?, key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if value == nil {
            defaults.removeObjectForKey(key)
        }
        else {
            defaults.setObject(value, forKey: key)
        }
        
        defaults.synchronize()
    }
    
    func getStringPreference(key: String) -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(key) != nil) {
            return defaults.objectForKey(key) as? String
        }
        else {
            return nil
        }
    }
    
    func getBoolPreference(key: String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(key)
    }
    
    func setBoolPreference(value: Bool, key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(value, forKey: key)
        defaults.synchronize()
    }
    
    func removePreferenceForKey(key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
        defaults.synchronize()
    }
}
