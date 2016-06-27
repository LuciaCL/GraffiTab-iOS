//
//  GeneralSettingsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class GeneralSettingsViewController: BackButtonTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func showInfoViewController(title: String, file: String) {
        let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: NSBundle.mainBundle())
        let infoVC = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        infoVC.title = title
        infoVC.filePath = file
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}
