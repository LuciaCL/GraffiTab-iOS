//
//  TintButton.swift
//  MassAlert
//
//  Created by Georgi Christov on 02/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class TintButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    func basicInit() {
        self.setImage(self.imageView?.image!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    }
}
