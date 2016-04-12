//
//  SettingsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class SettingsViewController: GeneralSettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickLogout() {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        GTUserManager.logout({ (response) in
            self.view.hideActivityView()
            
            Utils.logoutUserAndShowLoginController()
        }) { (response) in
            self.view.hideActivityView()
            
            Utils.logoutUserAndShowLoginController()
        }
    }

    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 3 {
            if indexPath.row == 0 { // Terms.
                showInfoViewController("Terms of Use", file: NSBundle.mainBundle().pathForResource("terms", ofType: "html")!)
            }
            else if indexPath.row == 1 { // EULA.
                showInfoViewController("End User License Agreement", file: NSBundle.mainBundle().pathForResource("eula", ofType: "html")!)
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 { // Logout.
                DialogBuilder.showYesNoAlert("Are you sure you want to log out?", title: App.Title, yesTitle: "Logout", noTitle: "Cancel", yesAction: { 
                    self.onClickLogout()
                }, noAction: {})
            }
        }
    }
}
