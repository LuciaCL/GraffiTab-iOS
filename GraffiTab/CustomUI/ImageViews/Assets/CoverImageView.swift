//
//  CoverImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 01/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class CoverImageView: AssetImageView {
    
    override var image: UIImage? {
        didSet {
            basicInit()
        }
    }
    
    override func basicInit() {
        super.basicInit()
        
        if self.image == nil {
            self.image = getClearCoverImage()
        }
    }
    
    // MARK: - Default image loading
    
    func getClearCoverImage() -> UIImage {
        return UIImage(named: "grafitab_login")!
    }
}
