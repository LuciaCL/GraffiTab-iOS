//
//  MaterializeRoundButton.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class MaterializeRoundButton: TintButton {

    override func basicInit() {
        super.basicInit()
        
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.blackColor().CGColor;
        self.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }
}
