//
//  GTDarkTheme.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class GTDarkTheme: GTTheme {

    override init() {
        super.init()
        
        // Colors.
        self.navigationBarBackgroundColor = self.primaryColor
        self.navigationBarElementsColor = UIColor.whiteColor()
        self.navigationBarLoadingIndicatorStyle = UIActivityIndicatorViewStyle.White
        self.navigationBarProfileElementsColor = self.navigationBarElementsColor
        self.navigationBarProfileElementsWithNavigationBarColor = self.navigationBarProfileElementsWithNavigationBarColor
        
        // Status bar.
        self.defaultStatusBarStyle = UIStatusBarStyle.LightContent
        self.loginStatusBarStyle = UIStatusBarStyle.LightContent
        self.mapStatusBarStyle = UIStatusBarStyle.Default
        self.mapTerrainStatusBarStyle = UIStatusBarStyle.LightContent
        self.detailsStatusBarStyle = UIStatusBarStyle.LightContent
        self.profileStatusBarStyle = UIStatusBarStyle.LightContent
        self.profileStatusBarWithNavigationBarStyle = UIStatusBarStyle.LightContent
        self.menuStatusBarStyle = UIStatusBarStyle.LightContent
    }
}
