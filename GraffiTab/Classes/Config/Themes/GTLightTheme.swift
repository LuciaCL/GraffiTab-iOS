//
//  GTLightTheme.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class GTLightTheme: GTTheme {

    override init() {
        super.init()
        
        // Colors.
        self.navigationBarBackgroundColor = UIColor.whiteColor()
        self.navigationBarElementsColor = self.primaryColor
        self.navigationBarLoadingIndicatorStyle = UIActivityIndicatorViewStyle.Gray
        self.navigationBarProfileElementsColor = UIColor.whiteColor()
        self.navigationBarProfileElementsWithNavigationBarColor = self.primaryColor
        
        // Status bar.
        self.defaultStatusBarStyle = UIStatusBarStyle.Default
        self.loginStatusBarStyle = UIStatusBarStyle.LightContent
        self.mapStatusBarStyle = UIStatusBarStyle.Default
        self.mapTerrainStatusBarStyle = UIStatusBarStyle.LightContent
        self.detailsStatusBarStyle = UIStatusBarStyle.LightContent
        self.profileStatusBarStyle = UIStatusBarStyle.LightContent
        self.profileStatusBarWithNavigationBarStyle = UIStatusBarStyle.Default
        self.menuStatusBarStyle = UIStatusBarStyle.LightContent
    }
}
