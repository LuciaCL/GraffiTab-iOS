//
//  ImageCellPresentationAnimator.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import INSImageView

class ImageCellPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        snapshotView.frame = openingFrame!
        snapshotView.backgroundColor = UIColor.blackColor()
        snapshotView.contentMode = animatedView!.contentMode
        snapshotView.clipsToBounds = animatedView!.clipsToBounds
        containerView!.addSubview(snapshotView)
        
        toViewController!.view.alpha = 0.0
        containerView!.addSubview(toViewController!.view)
        
        // Perform animations.
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            snapshotView.frame = fromViewController.view.frame
            snapshotView.contentMode = .ScaleAspectFit
        }, completion: { (finished) -> Void in
            if finished {
                snapshotView.removeFromSuperview()
                self.toViewController!.view.alpha = 1.0
                
                transitionContext.completeTransition(finished)
            }
        })
    }
}
