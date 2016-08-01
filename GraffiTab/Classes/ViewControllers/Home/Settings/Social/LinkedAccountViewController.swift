//
//  LinkedAccountViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 20/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import RNActivityView
import CocoaLumberjack

class LinkedAccountViewController: BackButtonTableViewController {

    var accountProvider: GTExternalProviderType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_SOCIAL_FRIENDS" {
            let vc = segue.destinationViewController as! SocialFriendsViewController
            vc.accountProvider = accountProvider
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to unlink account")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("linked_accounts_unlink", label: self.accountProvider?.rawValue)
            
            DialogBuilder.showYesNoAlert("Are you sure you want to unlink this account?", title: App.Title, yesTitle: "Unlink", yesAction: {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.unlinkExternalProvider(self.accountProvider!, successBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showSuccessAlert("This account has successfully been unlinked.", title: App.Title, okAction: {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true)
                })
            }, noAction: { 
                
            })
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        if accountProvider == .FACEBOOK {
            self.title = "Facebook"
        }
        else if accountProvider == .TWITTER {
            self.title = "Twitter"
        }
        else if accountProvider == .GOOGLE {
            self.title = "Google"
        }
    }
}
