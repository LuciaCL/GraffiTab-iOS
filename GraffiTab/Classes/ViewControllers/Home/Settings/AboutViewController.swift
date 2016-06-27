//
//  AboutViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AboutViewController: GeneralSettingsViewController {

    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var buildCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadInfo()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Loading
    
    func loadInfo() {
        versionCell.detailTextLabel?.text = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
        buildCell.detailTextLabel?.text = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as? String
    }

    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            showInfoViewController("Release notes", file: NSBundle.mainBundle().pathForResource("release_notes", ofType: "html")!)
        }
    }
}
