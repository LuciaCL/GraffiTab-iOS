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
            streamableThumbnail.image = nil
            
            Alamofire.request(.GET, (streamable?.asset?.thumbnail)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == streamable?.asset?.thumbnail { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.streamableThumbnail,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.streamableThumbnail.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
    
    func loadAvatar() {
        let user = getActionUser()
        
        avatar.image = nil
        
        if user != nil && user!.avatar != nil {
            Alamofire.request(.GET, (user!.avatar?.thumbnail)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.avatar,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.avatar.image = image
                            },
                            completion: nil)
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
