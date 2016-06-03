//
//  DeveloperOptionsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class DeveloperOptionsViewController: BackButtonTableViewController {

    @IBOutlet weak var domainField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        // Save properties.
        let domain = domainField.text
        
        if domain?.characters.count <= 0 {
            DialogBuilder.showAPIErrorAlert("Please enter a domain value", title: App.Title)
            return
        }
        
        GTSettings.sharedInstance.setAppDomain(domain!)
        Settings.sharedInstance.appDomain = domain
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Loading
    
    func loadData() {
        let domain = GTSettings.sharedInstance.appDomain()
        var localDomain = Settings.sharedInstance.appDomain
        
        if localDomain == nil {
            localDomain = domain
        }
        
        domainField.text = localDomain
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Developer Options"
    }
}
