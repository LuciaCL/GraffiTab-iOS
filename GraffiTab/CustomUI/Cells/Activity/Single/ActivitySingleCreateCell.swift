//
//  ActivitySingleCreateCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ActivitySingleCreateCell: ActivitySingleCell {

    override class func reusableIdentifier() -> String {
        return "ActivitySingleCreateCell"
    }
    
    override func getActionText() -> NSAttributedString? {
        let text = String(format: NSLocalizedString("cell_activity_created_single", comment: ""), item!.user!.getFullName())
        
        let attString = NSMutableAttributedString(string: text)
        let range = (text as NSString).rangeOfString(item!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        return attString
    }
    
    override func getActionStreamable() -> GTStreamable? {
        let activity = item?.activities?.first
        return activity?.createdStreamable
    }
}
