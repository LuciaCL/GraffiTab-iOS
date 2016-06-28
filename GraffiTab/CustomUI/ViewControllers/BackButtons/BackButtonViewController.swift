//
//  BackButtonViewController.swift
//  Brand2Generic
//
//  Created by Georgi Christov on 24/11/2015.
//  Copyright © 2015 Futurist Labs. All rights reserved.
//

import UIKit
import CocoaLumberjack

class BackButtonViewController: UIViewController {

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
