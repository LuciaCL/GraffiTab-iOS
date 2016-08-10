//
//  AboutViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AboutViewController: GeneralSettingsViewController {

    @IBOutlet weak var releaseInfoLbl: UILabel!
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var buildLbl: UILabel!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var buildCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
        
        loadInfo()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
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
            showInfoViewController(NSLocalizedString("controller_about_release_notes", comment: ""), file: NSBundle.mainBundle().pathForResource("release_notes", ofType: "html")!)
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_about_version_info", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("controller_about_copyright", comment: "")
        }
        
        return nil
    }
    
    // MARK: - Setup
    
    func setupLabels() {
        releaseInfoLbl.text = NSLocalizedString("controller_about_release_info", comment: "")
        versionLbl.text = NSLocalizedString("controller_about_version", comment: "")
        buildLbl.text = NSLocalizedString("controller_about_build", comment: "")
    }
}
