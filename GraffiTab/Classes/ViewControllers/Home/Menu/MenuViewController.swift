//
//  MenuViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class MenuViewController: BackButtonViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var rowHeight: CGFloat = DeviceType.IS_IPAD ? 65 : 50
    var rowTitles: [String] = [NSLocalizedString("controller_menu_profile", comment: ""), NSLocalizedString("controller_menu_locations", comment: ""), NSLocalizedString("controller_menu_search", comment: ""), NSLocalizedString("controller_menu_settings", comment: "")]
    var rowIcons: [String] = ["user_male4", "map_marker", "search", "settings"]
    var badgeValue: Int = 0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRectMake(0, self.view.frame.height / 2 - rowHeight * CGFloat(rowTitles.count) / 2, self.view.frame.width, rowHeight * CGFloat(rowTitles.count))
    }

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        
        cell.titleLbl.text = rowTitles[indexPath.row]
        cell.iconView?.image = UIImage(named: rowIcons[indexPath.row])?.imageWithRenderingMode(.AlwaysTemplate)
        
        if indexPath.row == 1 {
            cell.setBadgeNumber(badgeValue)
        }
        else {
            cell.setBadgeNumber(0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let mainVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as! MenuContainerViewController
        mainVC.hideMenuViewController()
        
        Utils.runWithDelay(0.3) { () in
            let nav = mainVC.contentViewController as! UINavigationController
            let homeVC = nav.viewControllers.first as! HomeViewController
            
            if indexPath.row == 0 {
                homeVC.onClickProfile(nil)
            }
            else if indexPath.row == 1 {
                homeVC.onClickLocations(nil)
            }
            else if indexPath.row == 2 {
                homeVC.onClickSearch(nil)
            }
            else if indexPath.row == 3 {
                homeVC.onClickSettings(nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView()
    }
}
