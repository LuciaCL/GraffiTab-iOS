//
//  RecentViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class RecentViewController: SwimLaneStreamablesViewController {
    
    // MARK: - Events
    
    override func registerForEvents() {
        super.registerForEvents()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.streamableCreatedEventHandler(_:)), name: GTEvents.StreamableCreated, object: nil)
    }
    
    func streamableCreatedEventHandler(notification: NSNotification) {
        let s = notification.userInfo!["streamable"] as! GTStreamable
        items.insert(s, atIndex: 0)
        collectionView.reloadData()
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTStreamableManager.getNewest(offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
}
