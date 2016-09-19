//
//  ViewController+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 25/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIViewController {

    func removeNavigationBarBackground(color: UIColor? = AppConfig.sharedInstance.theme?.navigationBarBackgroundColor) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: color!), forBarMetrics: .Default)
    }
}
