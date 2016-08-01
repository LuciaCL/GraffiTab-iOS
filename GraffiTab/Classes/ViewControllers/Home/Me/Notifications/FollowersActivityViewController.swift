//
//  FollowersActivityViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GraffiTab_iOS_SDK
import CarbonKit

class FollowersActivityViewController: BackButtonViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var pullToRefresh = CarbonSwipeRefresh()
    
    var items = [GTActivityContainer]()
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
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            initialLoad = true
            
            loadItems(true, offset: offset)
        }
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
        
        loadItems(isStart, offset: offset, cacheBlock: { (response) in
            self.items.removeAll()
            
            let listItemsResult = response.object as! GTListItemsResult<GTActivityContainer>
            self.items.appendContentsOf(listItemsResult.items!)
            
            self.finalizeCacheLoad()
        }, successBlock: { (response) in
            if offset == 0 {
                self.items.removeAll()
                
                let listItemsResult = response.object as! GTListItemsResult<GTActivityContainer>
                self.items.appendContentsOf(listItemsResult.items!)
                
                self.finalizeCacheLoad()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTActivityContainer>
            self.items.appendContentsOf(listItemsResult.items!)
            
            if listItemsResult.items!.count <= 0 && listItemsResult.items!.count < GTConstants.MaxItems {
                self.canLoadMore = false
            }
            
            self.finalizeLoad()
        }) { (response) in
            self.canLoadMore = false
            
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title)
        }
    }
    
    func finalizeCacheLoad() {
        self.tableView!.reloadData()
    }
    
    func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTMeManager.getFollowersActivity(offset: offset, limit: 20, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
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
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
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
        let cell: ActivitySingleCell
        let item = items[indexPath.row]
        
        if item.activities?.count == 1 { // List single activities.
            if item.type == .FOLLOW {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivitySingleFollowCell.reusableIdentifier()) as! ActivitySingleFollowCell
            }
            else if item.type == .COMMENT {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivitySingleCommentCell.reusableIdentifier()) as! ActivitySingleCommentCell
            }
            else if item.type == .LIKE {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivitySingleLikeCell.reusableIdentifier()) as! ActivitySingleLikeCell
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivitySingleCreateCell.reusableIdentifier()) as! ActivitySingleCreateCell
            }
        }
        else { // List grouped activities.
            if item.type == .FOLLOW {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivityGroupFollowCell.reusableIdentifier()) as! ActivityGroupFollowCell
            }
            else if item.type == .COMMENT {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivityGroupCommentCell.reusableIdentifier()) as! ActivityGroupCommentCell
            }
            else if item.type == .LIKE {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivityGroupLikeCell.reusableIdentifier()) as! ActivityGroupLikeCell
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier(ActivityGroupCreateCell.reusableIdentifier()) as! ActivityGroupCreateCell
            }
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
        
        if item.activities?.count == 1 { // List single activities.
            if item.type == .FOLLOW {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ActivitySingleFollowCell
                ViewControllerUtils.showUserProfile(cell.getSecondaryUser()!, viewController: self)
            }
            else if item.type == .COMMENT {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ActivitySingleCommentCell
                ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
            }
            else if item.type == .LIKE {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ActivitySingleLikeCell
                ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
            }
            else if item.type == .CREATE_STREAMABLE {
                let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ActivitySingleCreateCell
                ViewControllerUtils.showStreamableDetails(cell.getActionStreamable()!, modalPresentationStyle: nil, transitioningDelegate: nil, viewController: self)
            }
        }
        else { // List grouped activities.
            if item.type == .FOLLOW {
                var users = [GTUser]()
                for activity in item.activities! {
                    users.append(activity.followed!)
                }
                if users.count > 0 {
                    ViewControllerUtils.showStaticUsers(users, viewController: self)
                }
            }
            else if item.type == .COMMENT {
                var streamables = [GTStreamable]()
                for activity in item.activities! {
                    streamables.append(activity.commentedStreamable!)
                }
                if streamables.count > 0 {
                    ViewControllerUtils.showStaticStreamables(streamables, viewController: self)
                }
            }
            else if item.type == .LIKE {
                var streamables = [GTStreamable]()
                for activity in item.activities! {
                    streamables.append(activity.likedStreamable!)
                }
                if streamables.count > 0 {
                    ViewControllerUtils.showStaticStreamables(streamables, viewController: self)
                }
            }
            else if item.type == .CREATE_STREAMABLE {
                var streamables = [GTStreamable]()
                for activity in item.activities! {
                    streamables.append(activity.createdStreamable!)
                }
                if streamables.count > 0 {
                    ViewControllerUtils.showStaticStreamables(streamables, viewController: self)
                }
            }
        }
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String {
        return "No activity"
    }
    
    func getEmptyDataSetDescription() -> String {
        return "Looks like we don't have any activity to display yet. Please come back again."
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
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        
        // Setup pull to refresh.
        pullToRefresh = CarbonSwipeRefresh(scrollView: self.tableView)
        pullToRefresh.setMarginTop(0)
        pullToRefresh.colors = [UIColor(hexString: Colors.Main)!, UIColor(hexString: Colors.Orange)!, UIColor(hexString: Colors.Green)!]
        self.view.addSubview(pullToRefresh)
        pullToRefresh.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        // Setup infite scroll.
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
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
