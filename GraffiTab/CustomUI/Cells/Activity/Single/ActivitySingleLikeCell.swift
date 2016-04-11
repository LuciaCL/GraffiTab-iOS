//
//  ActivitySingleLikeCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ActivitySingleLikeCell: ActivitySingleCell {

    override class func reusableIdentifier() -> String {
        return "ActivitySingleLikeCell"
    }
    
    override func getActionText() -> NSAttributedString? {
        let activity = item?.activities?.first
        let text = String(format: "%@ likes %@'s graffiti.", item!.user!.getFullName(), activity!.likedStreamable!.user!.getFullName())
        
        let attString = NSMutableAttributedString(string: text)
        var range = (text as NSString).rangeOfString(item!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        range = (text as NSString).rangeOfString(activity!.likedStreamable!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        return attString
    }
    
    override func getActionStreamable() -> GTStreamable? {
        let activity = item?.activities?.first
        return activity?.likedStreamable
    }
}
