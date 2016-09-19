//
//  UINavigationBar+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 19/09/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension UINavigationBar {

    func hideBottomHairline(animated: Bool) {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        if navigationBarImageView != nil {
            let animations = {
                navigationBarImageView?.alpha = 0
            }
            
            if animated {
                UIView.animateWithDuration(0.3, animations: {
                    animations()
                })
            }
            else {
                animations()
            }
        }
    }
    
    func showBottomHairline(animated: Bool) {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        if navigationBarImageView != nil {
            let animations = {
                navigationBarImageView?.alpha = 1
            }
            
            if animated {
                UIView.animateWithDuration(0.3, animations: {
                    animations()
                })
            }
            else {
                animations()
            }
        }
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
}
