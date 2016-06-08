//
//  UINavigationController+Orientation.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    // MARK: - Orientation
    
    override public func shouldAutorotate() -> Bool {
        if self.topViewController != nil {
            return self.topViewController!.shouldAutorotate()
        }
        
        return true
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if self.topViewController != nil {
            return self.topViewController!.supportedInterfaceOrientations()
        }
        
        return .All
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if self.topViewController != nil {
            self.topViewController?.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        }
    }
}
