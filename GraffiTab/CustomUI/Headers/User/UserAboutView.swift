//
//  UserAboutView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 18/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class UserAboutView: UIView {

    @IBOutlet weak var infoLbl: UILabel!
    
    var item: GTUser? {
        didSet {
            setItem()
        }
    }
    
    func setItem() {
        // Setup labels.
        self.infoLbl.attributedText = item!.aboutString(infoLbl)
    }
}
