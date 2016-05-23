//
//  LocationListCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 23/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class LocationListCell: LocationCell {

    @IBOutlet weak var menuBtn: UIImageView!
    @IBOutlet weak var trackerImg: UIImageView!
    @IBOutlet weak var thumbnailLeadingConstraint: NSLayoutConstraint!
    
    override class func reusableIdentifier() -> String {
        return "LocationListCell"
    }
    
    func setTrackerVisible(value: Bool) {
        trackerImg.hidden = !value
        thumbnailLeadingConstraint.constant = value ? 33 : 8
    }
    
    // MARK: - Setup
    
    override func setupImageViews() {
        super.setupImageViews()
        
        menuBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickOptions)))
    }
}
