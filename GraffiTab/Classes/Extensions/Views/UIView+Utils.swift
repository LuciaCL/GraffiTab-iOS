//
//  UIView+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 02/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIView {

    func applyMaterializeStyle(opacity: Float? = 0.5) {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.blackColor().CGColor;
        self.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        self.layer.shadowOpacity = opacity!
        self.layer.masksToBounds = false
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
