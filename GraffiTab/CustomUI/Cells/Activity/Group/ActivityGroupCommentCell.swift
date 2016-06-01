//
//  ActivityGroupCommentCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class ActivityGroupCommentCell: ActivityGroupCell {

    override class func reusableIdentifier() -> String {
        return "ActivityGroupCommentCell"
    }
    
    override func getActionText() -> NSAttributedString? {
        let targetText = String(format: "%li graffiti", item!.activities!.count)
        let text = String(format: "%@ commented on %@.", item!.user!.getFullName(), targetText)
        
        let attString = NSMutableAttributedString(string: text)
        var range = (text as NSString).rangeOfString(item!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        range = (text as NSString).rangeOfString(targetText)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        return attString
    }
    
    // MARK: - Loading
    
    override func loadImageForCollectionIndex(index: Int, view: UIImageView) {
        let streamable = item!.activities![index].commentedStreamable
        
        let thumbnail = view as? StreamableImageView
        thumbnail?.asset = streamable!.asset
    }
}
