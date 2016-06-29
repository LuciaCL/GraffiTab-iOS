//
//  LinkedAccountsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 19/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CocoaLumberjack
import RNActivityView

class LinkedAccountsViewController: BackButtonTableViewController {

    @IBOutlet weak var facebookImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        loadData()
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_LINKED_ACCOUNT" {
            let vc = segue.destinationViewController as! LinkedAccountViewController
            vc.accountProvider = GTExternalProviderType(rawValue: sender as! String)
        }
    }
    
    // MARK: - Accounts
    
    func handleFacebookAccount() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Handling Facebook account linking")
        
        let user = GTSettings.sharedInstance.user
        let isLinkedFacebook = user!.isLinkedAccount(.FACEBOOK)
        
        let successBlock = {
            self.performSegueWithIdentifier("SHOW_LINKED_ACCOUNT", sender: GTExternalProviderType.FACEBOOK.rawValue)
        }
        
        if !isLinkedFacebook {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            loginToFacebookWithSuccess(false, successBlock: { (userId, token, email, firstName, lastName) in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to link Facebook account")
                
                GTMeManager.linkExternalProvider(.FACEBOOK, externalId: userId, accessToken: token, successBlock: { (response) in
                    self.view.hideActivityView()
                    
                    self.loadData()
                    successBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    if (response.reason == .AlreadyExists) { // User has already linked Facebook account.
                        self.loadData()
                        successBlock()
                        return
                    }
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }, andFailure: { (error) in
                self.view.hideActivityView()
                
                DDLogError("Failed to login with Facebook - \(error)")
                DialogBuilder.showErrorAlert("Could not login to Facebook", title: App.Title)
            })
        }
        else {
            successBlock()
        }
    }
    
    // MARK: - Loading
    
    func loadData() {
        let user = GTSettings.sharedInstance.user
        if user?.linkedAccounts == nil {
            showLoadingIndicator()
            
            GTMeManager.getMyFullProfile(successBlock: { (response) in
                self.removeLoadingIndicator()
                self.loadData()
            }, failureBlock: { (response) in
                self.removeLoadingIndicator()
            })
        }
        
        facebookImg.tintColor = user!.isLinkedAccount(GTExternalProviderType.FACEBOOK) ? UIColor(hexString: "3B5998") : UIColor(hexString: "d0d0d0")
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func removeLoadingIndicator() {
        self.navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let user = GTSettings.sharedInstance.user
        if user?.linkedAccounts == nil {
            return
        }
        
        if indexPath.row == 0 { // Facebook
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("linked_accounts_facebook", label: nil)
            
            handleFacebookAccount()
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Linked Accounts"
    }
}
