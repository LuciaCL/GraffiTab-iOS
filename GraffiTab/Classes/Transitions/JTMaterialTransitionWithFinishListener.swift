//
//  JTMaterialTransitionWithFinishListener.swift
//  GraffiTab
//
//  Created by Georgi Christov on 25/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import JTMaterialTransition

class JTMaterialTransitionWithFinishListener: JTMaterialTransition {

    var toViewController: UIViewController?
    
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        toViewController!.beginAppearanceTransition(true, animated: true)
        
        super.animateTransition(transitionContext)
    }
    
    override func animationEnded(transitionCompleted: Bool) {
        if !transitionCompleted {
            toViewController!.view.transform = CGAffineTransformIdentity
        }
        else {
            toViewController!.endAppearanceTransition()
        }
    }
}
