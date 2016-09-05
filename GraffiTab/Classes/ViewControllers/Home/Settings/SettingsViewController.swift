//
//  SettingsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import UIActionSheet_Blocks
import CocoaLumberjack
import Instabug
import MZFormSheetPresentationController

class SettingsViewController: GeneralSettingsViewController {

    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var languageField: UILabel!
    @IBOutlet weak var editProfileLbl: UILabel!
    @IBOutlet weak var changePasswordLbl: UILabel!
    @IBOutlet weak var likedPostsLbl: UILabel!
    @IBOutlet weak var rememberMeLbl: UILabel!
    @IBOutlet weak var rememberMeXConstraint: NSLayoutConstraint!
    @IBOutlet weak var findFacebookFriendsLbl: UILabel!
    @IBOutlet weak var inviteFacebookFriendsLbl: UILabel!
    @IBOutlet weak var followersActivityLbl: UILabel!
    @IBOutlet weak var linkedAccountsLbl: UILabel!
    @IBOutlet weak var appCacheLbl: UILabel!
    @IBOutlet weak var drawingAssistantLbl: UILabel!
    @IBOutlet weak var drawingAssistantXConstraint: NSLayoutConstraint!
    @IBOutlet weak var helpCenter: UILabel!
    @IBOutlet weak var reportProblemLbl: UILabel!
    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var eulaLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var logoutLbl: UILabel!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var rememberCredentialsSwitch: UISwitch!
    @IBOutlet weak var showDrawingAssistantSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
        setupSwitches()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        loadData()
    }

    @IBAction func onSwitchRememberCredentials(sender: AnyObject) {
        Settings.sharedInstance.rememberCredentials = rememberCredentialsSwitch.on
    }
    
    @IBAction func onSwitchShowDrawingAssistant(sender: AnyObject) {
        Settings.sharedInstance.showedDrawingAssistant = !showDrawingAssistantSwitch.on
    }
    
    func onClickLogout() {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Logout")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("logout", label: nil)
        
        self.view.showActivityView()
        self.view.rn_activityView.dimBackground = false
        
        GTUserManager.logout({ (response) in
            self.view.hideActivityView()
            
            Utils.logoutUserAndShowLoginController()
        }) { (response) in
            self.view.hideActivityView()
            
            Utils.logoutUserAndShowLoginController()
        }
    }
    
    // MARK: - Accounts
    
    func handleFacebookAccount() {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Handling Facebook account linking")
        
        let user = GTMeManager.sharedInstance.loggedInUser
        let isLinkedFacebook = user!.isLinkedAccount(.FACEBOOK)
        
        let successBlock = {
            self.performSegueWithIdentifier("SHOW_SOCIAL_FRIENDS", sender: nil)
        }
        
        if !isLinkedFacebook {
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            loginToFacebookWithSuccess(false, successBlock: { (userId, token, email, firstName, lastName) in
                DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting to link Facebook account")
                
                GTMeManager.linkExternalProvider(.FACEBOOK, externalId: userId, accessToken: token, successBlock: { (response) in
                    self.view.hideActivityView()
                    
                    self.loadData()
                    successBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    if (response.error.reason == .EXTERNAL_PROVIDER_ALREADY_LINKED) { // User has already linked Facebook account.
                        self.loadData()
                        successBlock()
                        return
                    }
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }, andFailure: { (error) in
                self.view.hideActivityView()
                
                DDLogError("Failed to login with Facebook - \(error)")
                DialogBuilder.showErrorAlert(self, status: NSLocalizedString("controller_linked_accounts_facebook_login_error", comment: ""), title: App.Title)
            })
        }
        else {
            successBlock()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_SOCIAL_FRIENDS" {
            let vc = segue.destinationViewController as! SocialFriendsViewController
            vc.accountProvider = GTExternalProviderType.FACEBOOK
        }
    }
    
    // MARK: - Loading
    
    func loadData() {
        logoutCell.detailTextLabel?.text = GTMeManager.sharedInstance.loggedInUser?.getFullName()
        
        languageField.text = Settings.sharedInstance.language != nil ? AppConfig.sharedInstance.customLanguages[Settings.sharedInstance.language!] : NSLocalizedString("controller_language_system", comment: "")
        
        rememberCredentialsSwitch.on = Settings.sharedInstance.rememberCredentials!
        showDrawingAssistantSwitch.on = !Settings.sharedInstance.showedDrawingAssistant!
    }

    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                EditPasswordViewController.showPasswordEditController(self)
            }
            else if indexPath.row == 2 {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("UserLikedStreamablesViewController") as! UserLikedStreamablesViewController
                vc.user = GTMeManager.sharedInstance.loggedInUser
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 { // Find Facebook friends.
                handleFacebookAccount()
            }
            else if indexPath.row == 1 { // Invite Facebook friends.
                inviteFacebookFriends()
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 2 { // Clear app cache.
                let actionSheet = buildActionSheet(NSLocalizedString("controller_settings_clear_cache_prompt", comment: ""))
                actionSheet.addButtonWithTitle(NSLocalizedString("controller_settings_clear_cache", comment: ""), image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
                    AppImageCache.sharedInstance.clearDiskCache()
                }
                showActionSheet(actionSheet)
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 1 { // Report a problem.
                Instabug.invoke()
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 { // Terms.
                showInfoViewController(NSLocalizedString("controller_terms_title", comment: ""), file: NSBundle.mainBundle().pathForResource("terms", ofType: "html")!)
            }
            else if indexPath.row == 1 { // EULA.
                showInfoViewController(NSLocalizedString("controller_settings_eula", comment: ""), file: NSBundle.mainBundle().pathForResource("eula", ofType: "html")!)
            }
        }
        else if indexPath.section == 5 {
            if indexPath.row == 0 { // Logout.
                let actionSheet = buildActionSheet(NSLocalizedString("controller_settings_logout_prompt", comment: ""))
                actionSheet.addButtonWithTitle(NSLocalizedString("controller_settings_logout", comment: ""), image: UIImage(named: "ic_exit_to_app_white"), type: .Destructive) { (sheet) in
                    self.onClickLogout()
                }
                showActionSheet(actionSheet)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 1 { // Disable Facebook invites for now.
                return 0
            }
        }
        
        return tableView.rowHeight
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        rememberMeXConstraint.constant = cell.separatorInset.left
        drawingAssistantXConstraint.constant = cell.separatorInset.left
        
        if indexPath.section == 1 && indexPath.row == 1 { // Disable Facebook invites for now.
            cell.hidden = true
        }
        else {
            cell.hidden = false
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("controller_settings_account", comment: "")
        }
        else if section == 1 {
            return NSLocalizedString("controller_settings_discover", comment: "")
        }
        else if section == 2 {
            return NSLocalizedString("controller_menu_settings", comment: "")
        }
        else if section == 3 {
            return NSLocalizedString("controller_settings_support", comment: "")
        }
        else if section == 4 {
            return NSLocalizedString("controller_settings_about", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("controller_settings_remember_me_description", comment: "")
        }
        
        return nil
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("controller_menu_settings", comment: "")
    }
    
    func setupLabels() {
        languageLbl.text = NSLocalizedString("controller_settings_language", comment: "")
        editProfileLbl.text = NSLocalizedString("controller_edit_profile", comment: "")
        changePasswordLbl.text = NSLocalizedString("controller_settings_change_password", comment: "")
        likedPostsLbl.text = NSLocalizedString("controller_settings_liked_posts", comment: "")
        rememberMeLbl.text = NSLocalizedString("controller_settings_remember_me", comment: "")
        findFacebookFriendsLbl.text = NSLocalizedString("controller_settings_find_facebook_friends", comment: "")
        inviteFacebookFriendsLbl.text = NSLocalizedString("controller_settings_invite_facebook_friends", comment: "")
        followersActivityLbl.text = NSLocalizedString("controller_settings_followers_activity", comment: "")
        linkedAccountsLbl.text = NSLocalizedString("controller_settings_linked_accounts", comment: "")
        appCacheLbl.text = NSLocalizedString("controller_settings_clear_cache", comment: "")
        drawingAssistantLbl.text = NSLocalizedString("controller_settings_assistant", comment: "")
        helpCenter.text = NSLocalizedString("controller_settings_help_center", comment: "")
        reportProblemLbl.text = NSLocalizedString("controller_settings_feedback", comment: "")
        termsLbl.text = NSLocalizedString("controller_terms_title", comment: "")
        eulaLbl.text = NSLocalizedString("controller_settings_eula", comment: "")
        aboutLbl.text = NSLocalizedString("controller_settings_about", comment: "")
        logoutLbl.text = NSLocalizedString("controller_settings_logout", comment: "")
    }
    
    func setupSwitches() {
        rememberCredentialsSwitch.onTintColor = AppConfig.sharedInstance.theme?.primaryColor
        showDrawingAssistantSwitch.onTintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
}
