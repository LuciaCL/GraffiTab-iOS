//
//  FeedViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class FeedViewController: ListFullStreamablesViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
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
        GTMeManager.getFeed(offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    override func getEmptyDataSetTitle() -> String! {
        return NSLocalizedString("controller_feed_empty_title", comment: "")
    }
    
    override func getEmptyDataSetDescription() -> String! {
        return NSLocalizedString("controller_feed_empty_description", comment: "")
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(17), NSForegroundColorAttributeName:AppConfig.sharedInstance.theme!.primaryColor! as UIColor]
        
        return NSAttributedString(string: NSLocalizedString("controller_feed_draw", comment: ""), attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        let mainVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as! MenuContainerViewController
        let nav = mainVC.contentViewController as! UINavigationController
        let homeVC = nav.viewControllers.first as! HomeViewController
        homeVC.onClickCreate(nil)
    }
}
