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

class MyNotificationsViewController: BackButtonViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var items: [GTNotification]?
    var isDownloading: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        items = [GTNotification]()
        isDownloading = false
        
        setupTableView()
        
        loadItems(true, offset: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading
    
    func refresh() {
        loadItems(false, offset: 0)
    }
    
    func loadItems(isStart: Bool, offset: Int) {
        if items?.count <= 0 && isDownloading == false {
            if isStart {
                if loadingIndicator != nil {
                    loadingIndicator.startAnimating()
                }
            }
        }
        
        showLoadingIndicator()
        
        isDownloading = true
        
        GTMeManager.getNotifications(offset, successBlock: { (response) in
            if offset == 0 {
                self.items?.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTNotification>
            self.items?.appendContentsOf(listItemsResult.items!)
            
            self.finalizeLoad()
        }) { (response) in
            self.finalizeLoad()
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    func finalizeLoad() {
        removeLoadingIndicator()
        
        if loadingIndicator != nil {
            loadingIndicator.stopAnimating()
        }
        
        isDownloading = false
        
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
        return items!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NotificationCell
        let item = items![indexPath.row]
        
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
        cell.timelineBottomView.hidden = indexPath.row == (items?.count)! - 1 ? true : false
        
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
    }
}
