//
//  OnboardingScreenView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 02/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class OnboardingScreenView: UIView {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var screenshot: UIImageView!
    
    var item: OnboardingScreen? {
        didSet {
            setItem()
        }
    }
    
    func setItem() {
        title.text = item?.title
        subtitle.text = item?.subtitle
        screenshot.image = UIImage(named: item!.screenshot)
    }
}
