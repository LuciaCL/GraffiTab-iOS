//
//  MenuCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var iconView: TintImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupBadge()
        setupLabels()
    }
    
    func setBadgeNumber(number: Int) {
        if number > 0 {
            badgeLbl.text = "\(number)"
            badgeView.hidden = false
        }
        else {
            badgeView.hidden = true
        }
    }
    
    // MARK: - Setup
    
    func setupBadge() {
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
        badgeView.hidden = true
    }
    
    func setupLabels() {
        titleLbl.font = titleLbl.font.fontWithSize(DeviceType.IS_IPAD ? 24 : 18)
    }
}
