//
//  PresentationAnimator.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var animatedView: UIView?
    
    var openingFrame: CGRect?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        // add blurred background to the view
//        let fromViewFrame = fromViewController.view.frame
        let fromViewFrame = UIApplication.sharedApplication().keyWindow?.bounds
        
        UIGraphicsBeginImageContext(fromViewFrame!.size)
        fromViewController.view.drawViewHierarchyInRect(fromViewFrame!, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotView = toViewController.view.resizableSnapshotViewFromRect(toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        snapshotView.frame = openingFrame!
        containerView!.addSubview(snapshotView)
        
        toViewController.view.alpha = 0.0
        containerView!.addSubview(toViewController.view)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 20.0, options: [], animations: { () -> Void in
            snapshotView.frame = fromViewFrame!
            
            self.animatedView!.alpha = 0.0
        }, completion: { (finished) -> Void in
            snapshotView.removeFromSuperview()
            toViewController.view.alpha = 1.0
            
            transitionContext.completeTransition(finished)
        })
    }
}
