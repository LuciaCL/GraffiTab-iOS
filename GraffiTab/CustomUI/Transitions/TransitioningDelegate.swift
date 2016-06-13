//
//  TransitioningDelegate.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var presentationAnimator = PresentationAnimator()
    var dismissAnimator = DismissalAnimator()
    weak var animatedView: UIView? {
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
}
