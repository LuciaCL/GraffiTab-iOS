//
//  AppConfig.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AppConfig: NSObject {

    static var sharedInstance: AppConfig = AppConfig()
    
    var fallbackLanguage = "English"
    var languages = [
        "English" : "en_EN",
        "Español" : "es_ES",
        "Български" : "bg_BG"
    ]
    
    var isAppStore: Bool = false
    var useAnalytics: Bool = false
    
    var theme: GTTheme?
    
    // MARK: - Themes
    
    func applyTheme(theme: GTTheme) {
        self.theme = theme
        
        UINavigationBar.appearance().barTintColor = theme.navigationBarBackgroundColor
        UINavigationBar.appearance().tintColor = theme.navigationBarElementsColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : theme.navigationBarElementsColor!]
    }
}
