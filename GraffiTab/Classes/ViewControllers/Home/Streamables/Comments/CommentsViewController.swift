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

class CommentsViewController: BackButtonSlackViewController {

    var items = [GTComment]()
    var isDownloading = false
    var streamable: GTStreamable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
        setupSlackController()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.reusableIdentifier()) as! CommentCell
        
        cell.setItem(items[indexPath.row])
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
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
        
        // TODO:
    }
    
    // MARK: - SLKTextViewController
    
    override func didPressRightButton(sender: AnyObject!) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        let text = self.textView.text.copy()
        
        // Create new comment.
        let comment = GTComment(Map(mappingType: .FromJSON, JSONDictionary: [:]))
        comment?.createdOn = NSDate()
        comment?.text = text as? String
        comment?.streamable = streamable
        comment?.user = GTSettings.sharedInstance.user
        
        // Create comment in the backend.
        
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
        
//        self.findAutocompletes()
        
        super.didPressRightButton(sender)
    }
    
    override func didCommitTextEditing(sender: AnyObject!) {
        // TODO:
        super.didCommitTextEditing(sender)
    }
    
    override func canShowAutoCompletion() -> Bool {
        // TODO:
        return false
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        // TODO:
        return 0
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Comments"
    }
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0
    }
    
    func setupSlackController() {
        self.bounces = true
        self.shakeToClearEnabled = false
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = false
        self.inverted = true
        
        self.tableView.separatorStyle = .None
        let commentCellNib = UINib(nibName: CommentCell.reusableIdentifier(), bundle: NSBundle.mainBundle())
        self.tableView.registerNib(commentCellNib, forCellReuseIdentifier: CommentCell.reusableIdentifier())
        
        self.rightButton.setTitle("Post", forState: .Normal)
        
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()
        self.textInputbar.editorLeftButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        self.textInputbar.editorRightButton.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        
        self.textInputbar.autoHideRightButton = true
        self.textView.placeholder = "Write your comment here"
        
        self.typingIndicatorView.canResignByTouch = true
        
//        [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteUserCell"];
//        [self.autoCompletionView registerNib:[UINib nibWithNibName:@"AutocompleteHashCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutocompleteHashCell"];
//        [self registerPrefixesForAutoCompletion:@[@"@", @"#"]];
    }
}
