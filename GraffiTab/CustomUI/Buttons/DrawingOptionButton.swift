//
//  DrawingOptionButton.swift
//  GraffiTab
//
//  Created by Georgi Christov on 17/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class DrawingOptionButton: TintButton {

    override func basicInit() {
        super.basicInit()
        
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}
