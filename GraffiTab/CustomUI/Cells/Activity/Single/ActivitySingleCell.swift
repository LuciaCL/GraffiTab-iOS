//
//  ActivitySingleCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class ActivitySingleCell: UITableViewCell {

    @IBOutlet var dateField: UILabel!
    @IBOutlet var timelineTopView: UIView!
    @IBOutlet var timelineBottomView: UIView!
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var secondaryAvatar: AvatarImageView!
    @IBOutlet weak var streamableThumbnail: StreamableImageView!
    @IBOutlet weak var notificationField: UILabel!
    
    var item: GTActivityContainer?
    
    class func reusableIdentifier() -> String {
        return "ActivityCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupLabels()
        setupTimelineIndicators()
    }
    
    func setItem(item: GTActivityContainer?) {
        self.item = item
        
        // Setup labels.
        self.dateField.text = DateUtils.notificationTimePassedSinceDate((item?.date)!)
        self.notificationField.attributedText = getActionText()
        
        loadAvatar()
        loadSecondaryAvatar()
        loadStreamable()
    }
    
    func getActionStreamable() -> GTStreamable? {
        return nil
    }
    
    func getActionText() -> NSAttributedString? {
        return nil
    }
    
    func getSecondaryUser() -> GTUser? {
        return nil
    }
    
    // MARK: - Loading
    
    func loadStreamable() {
        let streamable = getActionStreamable()
        
        if streamable != nil {
            self.streamableThumbnail.asset = streamable!.asset
        }
    }
    
    func loadAvatar() {
        let user = item?.user
        
        if user != nil {
            self.avatar.asset = user!.avatar
        }
    }
    
    func loadSecondaryAvatar() {
        let user = getSecondaryUser()
        
        if user != nil {
            self.secondaryAvatar.asset = user!.avatar
        }
    }
    
    // MARK: - Setup
    
    func setupLabels() {
        notificationField.textColor = UIColor(hexString: Colors.Main)
    }
    
    func setupTimelineIndicators() {
        timelineTopView.backgroundColor = UIColor(hexString: "#f5f5f5")
        timelineBottomView.backgroundColor = UIColor(hexString: "#f5f5f5")
    }
}
