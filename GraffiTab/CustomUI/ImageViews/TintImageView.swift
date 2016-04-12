//
//  TintImageView.swift
//  MassAlert
//
//  Created by Georgi Christov on 10/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class TintImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    func basicInit() {
        if self.image != nil {
            self.image = self.image!.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            basicInit()
        }
    }
}
