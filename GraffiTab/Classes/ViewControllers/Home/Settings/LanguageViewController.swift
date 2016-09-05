//
//  LanguageViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class LanguageViewController: BackButtonTableViewController {

    var languagesArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        for (k, _) in AppConfig.sharedInstance.customLanguages {
            languagesArray.append(k)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    // MARK: - UITableViewController
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return languagesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell")
            
            cell?.textLabel?.text = NSLocalizedString("controller_language_system", comment: "")
            cell?.tintColor = AppConfig.sharedInstance.theme?.primaryColor
            
            if Settings.sharedInstance.language == nil {
                cell?.accessoryType = .Checkmark
            }
            else {
                cell?.accessoryType = .None
            }
            
            return cell!
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell")
            
            let item = languagesArray[indexPath.row]
            
            cell?.textLabel?.text = AppConfig.sharedInstance.customLanguages[item]
            cell?.tintColor = AppConfig.sharedInstance.theme?.primaryColor
            
            if item == Settings.sharedInstance.language {
                cell?.accessoryType = .Checkmark
            }
            else {
                cell?.accessoryType = .None
            }
            
            return cell!
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_language_prompt", comment: "")
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_language_prompt_description", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            Settings.sharedInstance.language = nil
        }
        else if indexPath.section == 1 {
            let item = languagesArray[indexPath.row]
            Settings.sharedInstance.language = item
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("controller_settings_language", comment: "")
    }
}
