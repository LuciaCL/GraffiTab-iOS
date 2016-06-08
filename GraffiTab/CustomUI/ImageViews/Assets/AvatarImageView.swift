//
//  AvatarImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class AvatarImageView: AssetImageView {

    override var image: UIImage? {
        didSet {
            basicInit()
        }
    }
    
    override func basicInit() {
        super.basicInit()
        
        if self.image == nil {
            self.image = getClearAvatarImage()
        }
        
        self.layer.cornerRadius = 5
        
        self.clipsToBounds = true
        self.contentMode = .ScaleAspectFill
    }
    
    // MARK: - Default image loading
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
    }
}
