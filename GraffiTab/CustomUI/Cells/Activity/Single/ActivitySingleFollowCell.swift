//
//  ActivitySingleFollowCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ActivitySingleFollowCell: ActivitySingleCell {

    override class func reusableIdentifier() -> String {
        return "ActivitySingleFollowCell"
    }
    
    override func getSecondaryUser() -> GTUser? {
        let activity = item?.activities?.first
        return activity?.followed
    }
    
    override func getActionText() -> NSAttributedString? {
        let activity = item?.activities?.first
        let text = String(format: NSLocalizedString("cell_activity_following", comment: ""), item!.user!.getFullName(), activity!.followed!.getFullName())
        
        let attString = NSMutableAttributedString(string: text)
        var range = (text as NSString).rangeOfString(item!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        range = (text as NSString).rangeOfString(activity!.followed!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        return attString
    }
}
