//
//  NotificationMentionCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class NotificationMentionCell: NotificationCell {

    @IBOutlet weak var textField: UILabel!
    
    override class func reusableIdentifier() -> String {
        return "NotificationMentionCell"
    }
    
    override func setItem(item: GTNotification?) {
        super.setItem(item)
    
        textField.text = item?.mentionedComment?.text
    }
    
    override func getActionUser() -> GTUser {
        return item!.mentioner!
    }
    
    override func getActionText() -> String? {
        return "%@ mentioned you in a comment:"
    }
    
    override func getActionStreamable() -> GTStreamable? {
        return item?.mentionedStreamable
    }
}
