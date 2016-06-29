//
//  SocialFriendsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 20/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class SocialFriendsViewController: TrendingUsersViewController {

    var accountProvider: GTExternalProviderType?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTMeManager.getSocialFriendsForNetwork(accountProvider!, offset: offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        if accountProvider == .FACEBOOK {
            self.title = "Facebook Friends"
        }
        else if accountProvider == .TWITTER {
            self.title = "Twitter Friends"
        }
        else if accountProvider == .GOOGLE {
            self.title = "Google Friends"
        }
    }
}
