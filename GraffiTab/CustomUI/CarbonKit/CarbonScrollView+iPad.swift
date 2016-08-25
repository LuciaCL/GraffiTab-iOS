//
//  CarbonScrollView+iPad.swift
//  GraffiTab
//
//  Created by Georgi Christov on 25/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CarbonKit

extension CarbonTabSwipeScrollView {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set segmented control height equal to scroll view height.
        var segmentRect = self.carbonSegmentedControl.frame
        segmentRect.size.height = CGRectGetHeight(self.frame)
        self.carbonSegmentedControl.frame = segmentRect
        
        // Min content width equal to scroll view width.
        var contentWidth = self.carbonSegmentedControl.getWidth()
        if (contentWidth < CGRectGetWidth(self.frame)) {
            contentWidth = CGRectGetWidth(self.frame) + 1
        }
        
        // Scroll view content size.
        self.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(self.frame));
        
        if DeviceType.IS_IPAD {
            let selfWidth = CGRectGetWidth(self.bounds)
            if ( self.carbonSegmentedControl.getWidth() < CGRectGetWidth(self.bounds)) {
                let difference = selfWidth - self.carbonSegmentedControl.getWidth()
                self.frame = CGRectMake(difference/2.0, 0, selfWidth, CGRectGetHeight(self.bounds))
            }
            else {
                let frame = self.frame
                if (!CGRectEqualToRect(frame, CGRectMake(0, 0, selfWidth, CGRectGetHeight(self.bounds)))) {
                    self.frame = CGRectMake(0, 0, selfWidth, CGRectGetHeight(self.bounds))
                }
            }
        }
    }
}