//
//  GTTheme.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class GTTheme: NSObject {

    var primaryColor = BrandColors.Primary
    var secondaryColor = BrandColors.Secondary
    var metadataColor = BrandColors.Metadata
    
    var collectionBackgroundColor = BrandColors.collectionBackground
    
    var linksColor = BrandColors.Links
    var mentionColor = BrandColors.Mentions
    var hashtagColor = BrandColors.Hashtags
    
    var tabsBackgroundColor = UIColor.whiteColor()
    var tabsElementsColor = BrandColors.Primary
    
    var navigationBarBackgroundColor: UIColor?
    var navigationBarElementsColor: UIColor?
    var navigationBarProfileElementsColor: UIColor?
    var navigationBarProfileElementsWithNavigationBarColor: UIColor?
    var navigationBarLoadingIndicatorStyle: UIActivityIndicatorViewStyle?
    
    var defaultStatusBarStyle: UIStatusBarStyle?
    var avatarPromptStatusBarStyle: UIStatusBarStyle?
    var loginStatusBarStyle: UIStatusBarStyle?
    var mapStatusBarStyle: UIStatusBarStyle?
    var mapTerrainStatusBarStyle: UIStatusBarStyle?
    var detailsStatusBarStyle: UIStatusBarStyle?
    var profileStatusBarStyle: UIStatusBarStyle?
    var profileStatusBarWithNavigationBarStyle: UIStatusBarStyle?
    var menuStatusBarStyle: UIStatusBarStyle?
}
