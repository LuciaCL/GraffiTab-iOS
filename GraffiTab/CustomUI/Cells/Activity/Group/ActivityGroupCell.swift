//
//  ActivityGroupCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ActivityGroupCell: ActivitySingleCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout()
    }
    
    override func setItem(item: GTActivityContainer?) {
        super.setItem(item)
        
        collectionView.reloadData()
    }
    
    // MARK: - Loading
    
    func loadImageForCollectionIndex(index: Int, view: UIImageView) {
        assert(false, "Should be implemented in subclass.")
    }
    
    // MARK: - ViewType-specific helpers
    
    func getSpacing() -> Int {
        return 2
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        return width
    }
    
    func getPadding(spacing: CGFloat) -> CGFloat {
        return spacing
    }
    
    func configureLayout() {
        var width: CGFloat
        var height: CGFloat
        let spacing = CGFloat(getSpacing())
        let padding = CGFloat(getPadding(spacing))
        
        width = collectionView.frame.height
        height = getHeight(width)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item!.activities!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActivityGroupCell", forIndexPath: indexPath)
        
        let image = cell.viewWithTag(1) as! UIImageView
        loadImageForCollectionIndex(indexPath.row, view: image)
        
        return cell
    }
    
    // MARK: - Setup
    
    func setupCollectionView() {
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }
}
