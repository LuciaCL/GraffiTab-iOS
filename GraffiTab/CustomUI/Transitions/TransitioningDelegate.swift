//
//  TransitioningDelegate.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var openingFrame: CGRect?
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentationAnimator = PresentationAnimator()
        presentationAnimator.openingFrame = openingFrame!
        return presentationAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissAnimator = DismissalAnimator()
        dismissAnimator.openingFrame = openingFrame!
        return dismissAnimator
    }
}
