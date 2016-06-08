//
//  IMGLYMainEditorViewController+Disabled.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import imglyKit

extension IMGLYMainEditorViewController {

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let collectionView = findCollectionView()
        if collectionView != nil {
            
            if actionButtons.count == 10 {
                actionButtons.removeAtIndex(5) // Remove crop tool.
                actionButtons.removeAtIndex(3) // Remove orientation tool.
                collectionView?.reloadData()
            }
        }
    }
    
    func findCollectionView() -> UICollectionView? {
        for view in bottomContainerView.subviews {
            if view.isKindOfClass(UICollectionView) {
                return view as? UICollectionView
            }
        }
        
        return nil
    }
    
    // MARK: - Orientation
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isPortrait() {
            return [.Portrait, .PortraitUpsideDown]
        }
        else {
            return [.LandscapeLeft, .LandscapeRight]
        }
    }
    
    func isPortrait() -> Bool {
        return self.view.frame.width < self.view.frame.height
    }
}
