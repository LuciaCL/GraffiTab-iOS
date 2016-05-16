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
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var secondaryAvatar: UIImageView!
    @IBOutlet weak var streamableThumbnail: UIImageView!
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
            streamableThumbnail.image = nil
            
            Alamofire.request(.GET, (streamable?.asset?.thumbnail)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == streamable?.asset?.thumbnail { // Verify we're still loading the current image.
                        self.streamableThumbnail.image = image
                    }
            }
        }
    }
    
    func loadAvatar() {
        let user = item?.user
        avatar.image = nil
        
        if user != nil && user!.avatar != nil {
            Alamofire.request(.GET, (user!.avatar?.thumbnail)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
    }
    
    func loadSecondaryAvatar() {
        let user = getSecondaryUser()
        
        if user != nil {
            secondaryAvatar.image = nil
            
            if user!.avatar != nil {
                Alamofire.request(.GET, (user!.avatar?.thumbnail)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if response.request?.URLString == user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                            self.secondaryAvatar.image = image
                        }
                }
            }
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
