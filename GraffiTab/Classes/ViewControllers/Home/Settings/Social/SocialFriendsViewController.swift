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
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTMeManager.getSocialFriendsForNetwork(accountProvider!, offset: offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        if accountProvider == .FACEBOOK {
            self.title = NSLocalizedString("controller_social_friends_facebook", comment: "")
        }
        else if accountProvider == .TWITTER {
            self.title = NSLocalizedString("controller_social_friends_twitter", comment: "")
        }
        else if accountProvider == .GOOGLE {
            self.title = NSLocalizedString("controller_social_friends_google", comment: "")
        }
    }
}
