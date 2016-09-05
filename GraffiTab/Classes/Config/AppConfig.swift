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
    
    var customLanguages = [
        "bg-BG" : "Български"
    ]
    
    var isAppStore: Bool = false
    var useAnalytics: Bool = false
    var maxUndoActions = 10
    
    var theme: GTTheme?
    
    // MARK: - Themes
    
    func applyTheme(theme: GTTheme) {
        self.theme = theme
        
        UINavigationBar.appearance().barTintColor = theme.navigationBarBackgroundColor
        UINavigationBar.appearance().tintColor = theme.navigationBarElementsColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : theme.navigationBarElementsColor!]
    }
}
