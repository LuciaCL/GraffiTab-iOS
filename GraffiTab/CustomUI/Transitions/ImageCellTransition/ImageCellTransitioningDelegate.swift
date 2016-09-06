//
//  ImageCellTransitioningDelegate.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class ImageCellTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var presentationAnimator = ImageCellPresentationAnimator()
    var dismissAnimator = ImageCellDismissalAnimator()
    weak var animatedView: UIImageView? {
        didSet {
            presentationAnimator.animatedView = animatedView!
            dismissAnimator.animatedView = animatedView!
        }
    }
    var openingFrame: CGRect? {
        didSet {
            presentationAnimator.openingFrame = openingFrame!
            dismissAnimator.openingFrame = openingFrame!
        }
    }
    
    func resetState() {
        self.animatedView!.alpha = 1.0
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
}
