//
//  UIView+RoundedCorners.swift
//  GraffiTab
//
//  Created by Georgi Christov on 24/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}
