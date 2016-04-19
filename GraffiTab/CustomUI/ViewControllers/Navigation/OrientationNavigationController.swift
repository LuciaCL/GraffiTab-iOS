//
//  OrientationNavigationController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class OrientationNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Orientation
    
    override func shouldAutorotate() -> Bool {
        return self.topViewController!.shouldAutorotate()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.topViewController!.supportedInterfaceOrientations()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.topViewController?.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
}
