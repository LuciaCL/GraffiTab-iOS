//
//  ViewController+NoNavigationBarViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 25/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIViewController {

    func removeNavigationBarBackground() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        var bounds = self.navigationController!.navigationBar.bounds
        bounds.size.height = bounds.size.height + 20
        bounds.origin.y = bounds.origin.y - 20
        let background = UIView()
        background.userInteractionEnabled = false
        background.backgroundColor = UIColor.whiteColor()
        background.frame = bounds
        background.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.navigationController!.navigationBar.addSubview(background)
        self.navigationController!.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.sendSubviewToBack(background)
    }
}
