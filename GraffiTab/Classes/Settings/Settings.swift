//
//  Settings.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class Settings: NSObject {

    static let sharedInstance = Settings()
    
    var rememberCredentials: Bool? {
        get {
            return getBoolPreference(SettingsKeys.kRememberCredentials)
        }
        set(newValue) {
            setBoolPreference(newValue!, key: SettingsKeys.kRememberCredentials)
        }
    }
    var username: String? {
        get {
            return getStringPreference(SettingsKeys.kUsername)
        }
        set(newValue) {
            setStringPreference(newValue!, key: SettingsKeys.kUsername)
        }
    }
    var password: String? {
        get {
            return getStringPreference(SettingsKeys.kPassword)
        }
        set(newValue) {
            setStringPreference(newValue!, key: SettingsKeys.kPassword)
        }
    }
    
    override init() {
        super.init()
        
        basicInit()
    }
    
    func basicInit() {
        
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
    
    func setStringPreference(value: String, key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
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
