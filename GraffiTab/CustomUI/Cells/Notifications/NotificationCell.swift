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
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var streamableThumbnail: UIImageView!
    @IBOutlet weak var notificationField: UILabel!
    
    var item: GTNotification?
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupImageViews()
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
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
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
            if streamable?.asset != nil {
                Alamofire.request(.GET, (streamable?.asset?.link)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if response.request?.URLString == streamable?.asset?.link { // Verify we're still loading the current image.
                            self.streamableThumbnail.image = image
                        }
                }
            }
            else {
                streamableThumbnail.image = nil
            }
        }
    }
    
    func loadAvatar() {
        let user = getActionUser()
        
        if user != nil && user!.avatar != nil {
            Alamofire.request(.GET, (user!.avatar?.link)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == user!.avatar?.link! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
        else {
            avatar.image = getClearAvatarImage()
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        avatar.layer.cornerRadius = 5
    }
    
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