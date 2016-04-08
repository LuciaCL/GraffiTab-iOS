//
//  ListFullStreamablesViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class ListFullStreamablesViewController: GenericStreamablesViewController {

    var shownIndexes: Set<NSIndexPath>?
    
    override func basicInit() {
        super.basicInit()
        
        shownIndexes = Set()
        
        setViewType(.ListFull)
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if !(shownIndexes?.contains(indexPath))! {
            shownIndexes?.insert(indexPath)
            
            let layer = cell.layer
            layer.transform = CATransform3DMakeTranslation(0, self.collectionView.frame.height - 50, 0.0);
            
            UIView.animateWithDuration(indexPath.row == 0 ? 0.0 : 0.8, delay: 0, options: .CurveEaseOut, animations: {
                cell.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
}
