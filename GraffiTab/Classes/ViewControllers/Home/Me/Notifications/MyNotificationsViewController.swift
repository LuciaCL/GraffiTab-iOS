//
//  MyNotificationsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GraffiTab_iOS_SDK
import CarbonKit

class MyNotificationsViewController: BackButtonViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var pullToRefresh = CarbonSwipeRefresh()
    
    var items = [GTNotification]()
    var isDownloading = false
    var canLoadMore = true
    var offset = 0
    var initialLoad = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerForEvents()
        
        setupTableView()
        
        pullToRefresh.startRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.defaultStatusBarStyle!, animated: true)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        // Clear app badge.
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            initialLoad = true
            
            loadItems(true, offset: offset)
            
            Utils.runWithDelay(1) {
                self.checkPermissions()
            }
        }
    }
    
    func canRefresh() -> Bool {
        return tableView != nil
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        GTPermissionsManager.manager.checkPermission(.Notifications, controller: self)
    }

    // MARK: - Events
    
    func registerForEvents() {
        // App events.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarClickEventHandler(_:)), name: Notifications.AppStatusBarTouched, object: nil)
    }
    
    func statusBarClickEventHandler(notification: NSNotification) {
        self.tableView!.setContentOffset(CGPointZero, animated: true)
    }
    
    // MARK: - Loading
    
    func refresh() {
        offset = 0
        canLoadMore = true
        
        loadItems(false, offset: offset)
    }
    
    func loadItems(isStart: Bool, offset: Int) {
        showLoadingIndicator()
        
        isDownloading = true
        
        loadItems(isStart, offset: offset, cacheBlock: { (response) -> Void in
            self.items.removeAll()
            
            let listItemsResult = response.object as! GTListItemsResult<GTNotification>
            self.items.appendContentsOf(listItemsResult.items!)
            
            self.finalizeCacheLoad()
        }, successBlock: { (response) in
            if offset == 0 {
                self.items.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTNotification>
            self.items.appendContentsOf(listItemsResult.items!)
            
            if listItemsResult.items!.count <= 0 || listItemsResult.items!.count < listItemsResult.limit! {
                self.canLoadMore = false
            }
            
            self.finalizeLoad()
        }) { (response) in
            self.canLoadMore = false
            
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, reason: response.error.reason)
        }
    }
    
    func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTMeManager.getNotifications(offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    func finalizeCacheLoad() {
        self.tableView!.reloadData()
    }
    
    func finalizeLoad() {
        pullToRefresh.endRefreshing()
        removeLoadingIndicator()
        
        isDownloading = false
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.finishInfiniteScroll()
        tableView.reloadData()
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: AppConfig.sharedInstance.theme!.navigationBarLoadingIndicatorStyle!)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func removeLoadingIndicator() {
        let reload = UIBarButtonItem(image: UIImage(named: "ic_refresh_white"), style: .Plain, target: self, action: #selector(GenericStreamablesViewController.refresh))
        self.navigationItem.setRightBarButtonItem(reload, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationCell
        let item = items[indexPath.row]
        
        if item.type == .FOLLOW {
            cell = tableView.dequeueReusableCellWithIdentifier(NotificationFollowCell.reusableIdentifier()) as! NotificationFollowCell
        }
        else if item.type == .COMMENT {
            cell = tableView.dequeueReusableCellWithIdentifier(NotificationCommentCell.reusableIdentifier()) as! NotificationCommentCell
        }
        else if item.type == .LIKE {
            cell = tableView.dequeueReusableCellWithIdentifier(NotificationLikeCell.reusableIdentifier()) as! NotificationLikeCell
        }
        else if item.type == .MENTION {
            cell = tableView.dequeueReusableCellWithIdentifier(NotificationMentionCell.reusableIdentifier()) as! NotificationMentionCell
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(NotificationWelcomeCell.reusableIdentifier()) as! NotificationWelcomeCell
        }
    
        cell.setItem(item)
        
        // Setup timeline views.
        cell.timelineTopView.hidden = indexPath.row == 0 ? true : false
        cell.timelineBottomView.hidden = indexPath.row == items.count - 1 ? true : false
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(hexString: "efefef")
        cell.selectedBackgroundView = cellBGView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = items[indexPath.row]
        
        if item.type == .FOLLOW {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! NotificationFollowCell
            ViewControllerUtils.showUserProfile(cell.getActionUser(), viewController: self)
        }
        else if item.type == .COMMENT {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! NotificationCommentCell
            ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
        }
        else if item.type == .LIKE {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! NotificationLikeCell
            ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
        }
        else if item.type == .MENTION {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! NotificationMentionCell
            ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
        }
        else { // Welcome.
            
        }
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String {
        return NSLocalizedString("controller_notifications_empty_title", comment: "")
    }
    
    func getEmptyDataSetDescription() -> String {
        return NSLocalizedString("controller_notifications_empty_description", comment: "")
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: getEmptyDataSetImageName())
        return nil
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(hexString: "909090")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetTitle()
        
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetDescription()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName:UIFont.systemFontOfSize(14), NSForegroundColorAttributeName:UIColor.lightGrayColor(), NSParagraphStyleAttributeName:paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return self.parentViewController?.isKindOfClass(UINavigationController) == true ? 64 / 2 : 0
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        self.view.backgroundColor = AppConfig.sharedInstance.theme?.collectionBackgroundColor
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // Setup pull to refresh.
        pullToRefresh = CarbonSwipeRefresh(scrollView: self.tableView)
        pullToRefresh.setMarginTop(0)
        pullToRefresh.colors = [AppConfig.sharedInstance.theme!.primaryColor!, AppConfig.sharedInstance.theme!.secondaryColor!]
        self.view.addSubview(pullToRefresh)
        pullToRefresh.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        // Setup infite scroll.
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        tableView.infiniteScrollIndicatorView?.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        tableView?.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            if self!.canLoadMore && !self!.isDownloading {
                self!.offset = self!.offset + GTConstants.MaxItems
                self?.loadItems(false, offset: self!.offset)
            }
            else {
                self?.isDownloading = false
                self?.tableView.finishInfiniteScroll()
            }
        }
    }
}
