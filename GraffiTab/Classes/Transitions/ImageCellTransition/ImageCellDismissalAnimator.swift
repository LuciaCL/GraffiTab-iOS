//
//  ImageCellDismissalAnimator.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import INSImageView

class ImageCellDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var animatedView: UIImageView?
    
    var openingFrame: CGRect?
    var toViewController: UIViewController?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animationEnded(transitionCompleted: Bool) {
        if !transitionCompleted {
            toViewController!.view.transform = CGAffineTransformIdentity
        }
        else {
            toViewController!.endAppearanceTransition()
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // Obtain common properties.
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        // Begin transition.
        toViewController!.beginAppearanceTransition(true, animated: true)
        
        // Create snapshot view.
        let snapshotView = INSImageView(image: animatedView?.image)
        snapshotView.frame = fromViewController.view.frame
        snapshotView.backgroundColor = UIColor.blackColor()
        snapshotView.contentMode = .ScaleAspectFit
        snapshotView.clipsToBounds = animatedView!.clipsToBounds
        containerView!.addSubview(snapshotView)
        
        fromViewController.view.alpha = 0.0
        
        // Perform animations.
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            snapshotView.frame = self.openingFrame!
            snapshotView.contentMode = self.animatedView!.contentMode
        }) { (finished) -> Void in
            if finished {
                snapshotView.removeFromSuperview()
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        }
    }
}
