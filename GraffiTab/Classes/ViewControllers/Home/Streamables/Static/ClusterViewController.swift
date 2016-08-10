//
//  ClusterViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ClusterViewController: GridStreamablesViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    // MARK: - Init
    
    override func basicInit() {
        showStaticCollection = true
        
        super.basicInit()
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // МАРК: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = String(format: NSLocalizedString("controller_streamable_cluster", comment: ""), items.count)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("other_close", comment: ""), style: .Plain, target: self, action: #selector(self.onClickClose(_:)))
    }
}
