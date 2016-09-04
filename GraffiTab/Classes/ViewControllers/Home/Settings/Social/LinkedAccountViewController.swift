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

    @IBOutlet weak var findFriendsLbl: UILabel!
    @IBOutlet weak var unlinkLbl: UILabel!
    
    var accountProvider: GTExternalProviderType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
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
            
            DialogBuilder.showYesNoAlert(self, status: NSLocalizedString("controller_linked_account_unlink_prompt", comment: ""), title: App.Title, yesTitle: NSLocalizedString("controller_linked_account_unlink_prompt_yes", comment: ""), yesAction: {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.unlinkExternalProvider(self.accountProvider!, successBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_linked_account_unlink_success", comment: ""), title: App.Title, okAction: {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }, noAction: { 
                
            })
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_settings_account", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_linked_account_unlink_description", comment: "")
        }
        
        return nil
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        if accountProvider == .FACEBOOK {
            self.title = NSLocalizedString("controller_linked_account_facebook", comment: "")
        }
        else if accountProvider == .TWITTER {
            self.title = NSLocalizedString("controller_linked_account_twitter", comment: "")
        }
        else if accountProvider == .GOOGLE {
            self.title = NSLocalizedString("controller_linked_account_google", comment: "")
        }
    }
    
    func setupLabels() {
        findFriendsLbl.text = NSLocalizedString("controller_linked_account_find_friends", comment: "")
        unlinkLbl.text = NSLocalizedString("controller_linked_account_unlink_prompt_yes", comment: "")
    }
}
