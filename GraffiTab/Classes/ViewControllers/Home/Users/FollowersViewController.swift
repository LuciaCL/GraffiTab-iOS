//
//  FollowersViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class FollowersViewController: ListUsersViewController {
    
    var user: GTUser?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getFollowers(user!.id!, offset: offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("controller_followers", comment: "")
    }
}
