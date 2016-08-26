//
//  UISlider+CustomFlat.swift
//  GraffiTab
//
//  Created by Georgi Christov on 22/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import FlatUIKit

extension UISlider {

    func configureFatSlider(trackColor: UIColor, progressColor: UIColor, thumbColorNormal: UIColor, thumbColorHighlighted: UIColor) {
        let size = CGFloat(self.frame.size.height)
        
        let progressImage = UIImage(color: progressColor, cornerRadius: size / 2).imageWithMinimumSize(CGSizeMake(size, size))
        let trackImage = UIImage(color: trackColor, cornerRadius: size / 2).imageWithMinimumSize(CGSizeMake(size, size))
        
        self.setMinimumTrackImage(progressImage, forState: .Normal)
        self.setMaximumTrackImage(trackImage, forState: .Normal)
        
        let normalSliderImage = UIImage.circularImageWithColor(thumbColorNormal, size: CGSizeMake(size, size))
        self.setThumbImage(normalSliderImage, forState: .Normal)
        
        let highlighedSliderImage = UIImage.circularImageWithColor(thumbColorHighlighted, size: CGSizeMake(size, size))
        self.setThumbImage(highlighedSliderImage, forState: .Highlighted)
    }
}
