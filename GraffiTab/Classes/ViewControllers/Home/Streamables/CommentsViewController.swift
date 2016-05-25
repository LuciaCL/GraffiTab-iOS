//
//  CommentsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import ObjectMapper
import CarbonKit

class CommentsViewController: BackButtonSlackViewController, MessageDelegate {

    var pullToRefresh = CarbonSwipeRefresh()
    
    var items = [GTComment]()
    var searchResults = NSMutableArray()
    var isDownloading = false
    var canLoadMore = true
    var offset = 0
    var streamable: GTStreamable?
    var commentToEdit: GTComment?
    var initialLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
        setupSlackController()
        
        pullToRefresh.startRefreshing()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
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
    
    func onClickClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        GTStreamableManager.getComments(streamable!.id!, offset: offset, successBlock: { (response) in
            if offset == 0 {
                self.items.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTComment>
            self.items.appendContentsOf(listItemsResult.items!)
            
            if listItemsResult.items!.count <= 0 && listItemsResult.items!.count < GTConstants.MaxItems {
                self.canLoadMore = false
            }
            
            self.finalizeLoad()
        }) { (response) in
            self.canLoadMore = false
            
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
        }
    }
    
    func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        assert(false, "Method should be overridden by subclass.")
    }
    
    func finalizeLoad() {
        pullToRefresh.endRefreshing()
        removeLoadingIndicator()
        
        isDownloading = false
        
        self.tableView.finishInfiniteScroll()
        self.tableView.reloadData()
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func removeLoadingIndicator() {
        let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refresh))
        self.navigationItem.setRightBarButtonItem(reload, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return items.count
        }
        
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.reusableIdentifier()) as! CommentCell
            
            cell.item = items[indexPath.row]
            cell.delegate = self
            
            // Cells must inherit the table view's transform
            // This is very important, since the main table view may be inverted
            cell.transform = self.tableView.transform
            
            return cell
        }
        else {
            if self.foundPrefix == "@" {
                let cell = tableView.dequeueReusableCellWithIdentifier(AutocompleteUserCell.reusableIdentifier()) as! AutocompleteUserCell
                cell.item = searchResults[indexPath.row] as? GTUser
                return cell
            }
            else if self.foundPrefix == "#" {
                let cell = tableView.dequeueReusableCellWithIdentifier(AutocompleteHashCell.reusableIdentifier()) as! AutocompleteHashCell
                cell.item = searchResults[indexPath.row] as? String
                return cell
            }
            
            assert(false, "Unsupported prefix - \(self.foundPrefix)")
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableView {
            let topView = UIView()
            topView.backgroundColor = self.autoCompletionView.separatorColor
            return topView
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.autoCompletionView {
            return 0.5
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if tableView == self.tableView {
            let comment = items[indexPath.row]
            var actions: [String]
            var destructiveTitle: String?
            let canEdit = comment.user!.isEqual(GTSettings.sharedInstance.user)
            if canEdit {
                actions = ["Edit", "Copy"]
                destructiveTitle = "Delete"
            }
            else {
                actions = ["Copy"]
            }
            
            UIActionSheet.showInView(view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: destructiveTitle, otherButtonTitles: actions, tapBlock: { (actionSheet, index) in
                Utils.runWithDelay(0.3, block: {
                    if canEdit {
                        if index == 0 { // Delete.
                            self.doDeleteComment(comment, shouldDeleteRemotely: true)
                        }
                        else if index == 1 { // Edit.
                            self.commentToEdit = comment
                            self.editText(comment.text)
                            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                        }
                        else if index == 2 { // Copy.
                            UIPasteboard.generalPasteboard().string = comment.text
                        }
                    }
                    else {
                        if index == 0 { // Copy.
                            UIPasteboard.generalPasteboard().string = comment.text
                        }
                    }
                })
            })
        }
        else {
            var string: String?
            if self.foundPrefix == "@" {
                string = (searchResults[indexPath.row] as? GTUser)?.username
            }
            else {
                string = searchResults[indexPath.row] as? String
            }
            
            string = string! + " "
            self.acceptAutoCompletionWithString(string, keepPrefix: true)
        }
    }
    
    // MARK: - SLKTextViewController
    
    override func didPressRightButton(sender: AnyObject!) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        let text = self.textView.text.copy()
        let id = random()
        
        // Create new comment.
        let comment = GTComment(Map(mappingType: .FromJSON, JSONDictionary: [:]))
        comment?.id = id
        comment?.createdOn = NSDate()
        comment?.text = text as? String
        comment?.streamable = streamable
        comment?.user = GTSettings.sharedInstance.user
        
        // Create comment in the backend.
        doPostComment(comment!, shouldRefresh: false)
        
        // Add as new comment in the UI.
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
        let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top
        
        self.tableView.beginUpdates()
        items.insert(comment!, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
        
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        streamable?.commentsCount! += 1
        
        super.didPressRightButton(sender)
    }
    
    override func didCommitTextEditing(sender: AnyObject!) {
        let text = self.textView.text.copy()
        
        commentToEdit?.text = text as? String
        commentToEdit?.updatedOn = NSDate()
        self.tableView.reloadData()
        
        GTStreamableManager.editComment(streamable!.id!, commentId: commentToEdit!.id!, text: commentToEdit!.text!, successBlock: { (response) in
            
        }) { (response) in
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
        }
        
        super.didCommitTextEditing(sender)
    }
    
    override func didChangeAutoCompletionPrefix(prefix: String!, andWord word: String!) {
        searchResults.removeAllObjects()
        
        if prefix == "@" {
            if word.characters.count > 0 {
                GTUserManager.search(word, successBlock: { (response) in
                    let listItemsResult = response.object as! GTListItemsResult<GTUser>
                    self.searchResults.addObjectsFromArray(listItemsResult.items!)
                    
                    let show = (self.searchResults.count > 0)
                    self.showAutoCompletionView(show)
                    }, failureBlock: { (response) in
                        
                })
            }
        }
        else if prefix == "#" {
            if word.characters.count > 0 {
                GTStreamableManager.searchHashtags(word, successBlock: { (response) in
                    let listItemsResult = response.object as! GTListItemsResult<String>
                    self.searchResults.addObjectsFromArray(listItemsResult.items!)
                    
                    let show = (self.searchResults.count > 0)
                    self.showAutoCompletionView(show)
                    }, failureBlock: { (response) in
                        
                })
            }
        }
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        return self.autoCompletionView.rowHeight * CGFloat(min(searchResults.count, 5))
    }
    
    func doPostComment(comment: GTComment, shouldRefresh: Bool) {
        comment.status = .Sending
        
        if shouldRefresh {
            self.tableView.reloadData()
        }
        
        GTStreamableManager.postComment(streamable!.id!, text: comment.text!, successBlock: { (response) in
            let newComment = response.object as! GTComment
            comment.id = newComment.id
            comment.status = .Sent
            
            self.tableView.reloadData()
        }) { (response) in
            comment.status = .Failed
            
            self.tableView.reloadData()
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
        }
    }
    
    func doDeleteComment(comment: GTComment, shouldDeleteRemotely: Bool) {
        let indexPath = NSIndexPath(forRow: self.items.indexOf(comment)!, inSection: 0)
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        self.items.removeAtIndex(indexPath.row)
        self.tableView.endUpdates()
        
        if shouldDeleteRemotely {
            GTStreamableManager.deleteComment(streamable!.id!, commentId: comment.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
            })
        }
        
        streamable?.commentsCount! -= 1
        if streamable?.commentsCount < 0 {
            streamable?.commentsCount = 0
        }
    }
    
    // MARK: - MessageDelegate
    
    func didTapLink(link: String) {
        Utils.openUrl(link)
    }
    
    func didTapHashtag(hashtag: String) {
        // TODO:
    }
    
    func didTapUsername(username: String) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        GTUserManager.getUserProfileByUsername(username, successBlock: { (response) in
            self.view.hideActivityView()
            
            ViewControllerUtils.showUserProfile(response.object as! GTUser, viewController: self)
        }) { (response) in
            self.view.hideActivityView()
            
            if response.reason == .NotFound {
                DialogBuilder.showAPIErrorAlert(String(format: "User with username '\(username)' does not exist."), title: App.Title, forceShow: true)
                return
            }
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
        }
    }
    
    func didTapErrorView(comment: GTComment) {
        UIActionSheet.showInView(view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete", otherButtonTitles: ["Try again"], tapBlock: { (actionSheet, index) in
            if index == 0 {
                Utils.runWithDelay(0.3, block: {
                    self.doDeleteComment(comment, shouldDeleteRemotely: false)
                })
            }
            else if index == 1 {
                self.doPostComment(comment, shouldRefresh: true)
            }
        })
    }
    
    func didTapAvatar(user: GTUser) {
        ViewControllerUtils.showUserProfile(user, viewController: self)
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Comments"
        
        if self.navigationController?.viewControllers.count <= 1 { // We're running in a container so show a close button.
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(onClickClose))
        }
    }
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
        
        self.autoCompletionView.tableFooterView = UIView()
        self.autoCompletionView.rowHeight = 44
        self.autoCompletionView.separatorStyle = .None
    }
    
    func setupSlackController() {
        self.bounces = true
        self.shakeToClearEnabled = false
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.inverted = true
        
        self.tableView.separatorStyle = .None
        self.tableView.registerNib(UINib(nibName: CommentCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: CommentCell.reusableIdentifier())
        
        self.rightButton.setTitle("Post", forState: .Normal)
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        
        self.textInputbar.autoHideRightButton = true
        self.textView.placeholder = "Write your comment here"
        
        self.typingIndicatorView.canResignByTouch = true
        
        self.autoCompletionView.registerNib(UINib(nibName: AutocompleteUserCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: AutocompleteUserCell.reusableIdentifier())
        self.autoCompletionView.registerNib(UINib(nibName: AutocompleteHashCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellReuseIdentifier: AutocompleteHashCell.reusableIdentifier())
        self.registerPrefixesForAutoCompletion(["@", "#"])
        
        // Setup pull to refresh.
        pullToRefresh = CarbonSwipeRefresh(scrollView: self.tableView)
        pullToRefresh.setMarginTop(0)
        pullToRefresh.colors = [UIColor(hexString: Colors.Main)!, UIColor(hexString: Colors.Orange)!, UIColor(hexString: Colors.Green)!]
        self.tableView.addSubview(pullToRefresh)
        pullToRefresh.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        // Setup infite scroll.
        self.tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        self.tableView?.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
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
