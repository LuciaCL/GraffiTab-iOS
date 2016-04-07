//
//  MenuViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var rowHeight: CGFloat = 50
    var rowTitles: [String] = ["Profile", "Notifications", "Explore", "Settings"]
    var rowIcons: [String] = ["user_male4", "ic_notifications", "ic_explore", "settings"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.frame = CGRectMake(0, self.view.frame.height / 2 - rowHeight * CGFloat(rowTitles.count) / 2, self.view.frame.width, rowHeight * CGFloat(rowTitles.count))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        
        cell.titleLbl.text = rowTitles[indexPath.row]
        cell.iconView?.image = UIImage(named: rowIcons[indexPath.row])?.imageWithRenderingMode(.AlwaysTemplate)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView()
    }
}
