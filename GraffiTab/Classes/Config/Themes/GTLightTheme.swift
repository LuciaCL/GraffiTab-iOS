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
        self.primaryColor = UIColor(hexString: "#005c86", alpha: 0.9)
        self.secondaryColor = UIColor(hexString: "#e9a13a")
        
        self.navigationBarBackgroundColor = UIColor.whiteColor()
        self.navigationBarElementsColor = self.primaryColor
        self.navigationBarProfileElementsColor = UIColor.whiteColor()
        self.navigationBarLoadingIndicatorStyle = UIActivityIndicatorViewStyle.Gray
        
        self.collectionBackgroundColor = UIColor(hexString: "#f0f0f0")
        self.confirmationColor = UIColor(hexString: "#6cbd52")
        
        self.linksColor = UIColor(hexString: "#ef6a0e")
        self.mentionColor = UIColor(hexString: "#3F739A")
        self.hashtagColor = UIColor(hexString: "#3F739A")
        
        self.tabsBackgroundColor = UIColor.whiteColor()
        self.tabsElementsColor = self.primaryColor
        
        // Status bar.
        self.defaultStatusBarStyle = UIStatusBarStyle.Default
        self.loginStatusBarStyle = UIStatusBarStyle.LightContent
        self.mapStatusBarStyle = UIStatusBarStyle.Default
        self.mapTerrainStatusBarStyle = UIStatusBarStyle.LightContent
        self.detailsStatusBarStyle = UIStatusBarStyle.LightContent
        self.profileStatusBarStyle = UIStatusBarStyle.LightContent
        self.menuStatusBarStyle = UIStatusBarStyle.LightContent
    }
}
