//
//  AvatarImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AvatarImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    func basicInit() {
        if self.image == nil {
            self.image = getClearAvatarImage()
        }
        
        self.layer.cornerRadius = 5
    }
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
    }
    
    override var image: UIImage? {
        didSet {
            basicInit()
        }
    }
}
