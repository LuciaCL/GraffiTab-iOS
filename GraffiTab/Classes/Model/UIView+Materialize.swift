//
//  UIView+Materialize.swift
//  GraffiTab
//
//  Created by Georgi Christov on 02/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIView {

    func applyMaterializeStyle() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.blackColor().CGColor;
        self.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }
}
