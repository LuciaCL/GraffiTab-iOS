//
//  DismissalAnimator.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class DismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var animatedView: UIView?
    
    var openingFrame: CGRect?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        _ = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        let snapshotView = fromViewController.view.resizableSnapshotViewFromRect(fromViewController.view.bounds, afterScreenUpdates: false, withCapInsets: UIEdgeInsetsZero)
        containerView!.addSubview(snapshotView)
        
        fromViewController.view.alpha = 0.0
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            snapshotView.frame = self.openingFrame!
            snapshotView.alpha = 0.0
        }) { (finished) -> Void in
            snapshotView.removeFromSuperview()
            fromViewController.view.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0.13, options: [], animations: {
            self.animatedView!.alpha = 1.0
        }, completion: nil)
    }
}
