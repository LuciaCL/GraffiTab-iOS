//
//  NotificationCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class NotificationCell: UITableViewCell {

    @IBOutlet var dateField: UILabel!
    @IBOutlet var unreadIndicator: UIView!
    @IBOutlet var timelineTopView: UIView!
    @IBOutlet var timelineBottomView: UIView!
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var streamableThumbnail: StreamableImageView!
    @IBOutlet weak var notificationField: UILabel!
    
    var item: GTNotification?
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupLabels()
        setupTimelineIndicators()
    }
    
    func setItem(item: GTNotification?) {
        self.item = item
        
        // Setup labels.
        self.dateField.text = DateUtils.notificationTimePassedSinceDate((item?.date)!);
        
        setupNotificationText()
        
        unreadIndicator.hidden = (item?.isRead)!
        
        loadAvatar()
        loadStreamable()
    }
    
    func getActionUser() -> GTUser? {
        return nil
    }
    
    func getActionStreamable() -> GTStreamable? {
        return nil
    }
    
    func getActionText() -> String? {
        return nil
    }
    
    // MARK: - Loading
    
    func loadStreamable() {
        let streamable = getActionStreamable()
        
        if streamable != nil {
            streamableThumbnail.streamable = streamable
        }
    }
    
    func loadAvatar() {
        let user = getActionUser()
        
        if user != nil {
            self.avatar.user = user
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
    
    func setupNotificationText() {
        let user = getActionUser()
        let actionText = getActionText()
        
        if user != nil && actionText != nil {
            let text = String(format: actionText!, user!.getFullName())
            let attString = NSMutableAttributedString(string: text)
            let range = (text as NSString).rangeOfString(user!.getFullName())
            attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
            notificationField.attributedText = attString;
        }
    }
}
