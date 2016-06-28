//
//  BackButtonTableViewController.swift
//  MassAlert
//
//  Created by Georgi Christov on 04/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit
import CocoaLumberjack

class BackButtonTableViewController: UITableViewController {

    deinit {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupTopBar()
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // TODO: Respond to size change.
    }
    
    // MARK: - Setup
    
    func setupTopBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }
}
