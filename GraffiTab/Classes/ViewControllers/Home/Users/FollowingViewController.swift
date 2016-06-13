//
//  FollowingViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class FollowingViewController: ListUsersViewController {
    
    var user: GTUser?
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getFollowing(user!.id!, offset: offset, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Following"
    }
}
