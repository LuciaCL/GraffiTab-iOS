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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            initialLoad = true
            
            loadItems(true, offset: offset)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading
    
    func refresh() {
        offset = 0
        canLoadMore = true
        
        loadItems(false, offset: offset)
    }
    
    func loadItems(isStart: Bool, offset: Int) {
        if items.count <= 0 && isDownloading == false {
            if isStart {
                pullToRefresh.startRefreshing()
            }
        }
        
        showLoadingIndicator()
        
        isDownloading = true
        
        GTMeManager.getNotifications(offset, successBlock: { (response) in
            if offset == 0 {
                self.items.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTNotification>
            self.items.appendContentsOf(listItemsResult.items!)
            
            if listItemsResult.items!.count <= 0 && listItemsResult.items!.count < GTConstants.MaxItems {
                self.canLoadMore = false
            }
            
            self.finalizeLoad()
        }) { (response) in
            self.canLoadMore = false
            
            self.finalizeLoad()
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    func finalizeLoad() {
        pullToRefresh.endRefreshing()
        removeLoadingIndicator()
        
        isDownloading = false
        
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
        let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(GenericStreamablesViewController.refresh))
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
        
        
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String {
        return "No graffiti"
    }
    
    func getEmptyDataSetDescription() -> String {
        return "No graffiti were found over here. Please come back again."
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: getEmptyDataSetImageName())
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
        return -10
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
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
