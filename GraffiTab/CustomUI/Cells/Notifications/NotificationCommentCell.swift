//
//  NotificationCommentCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class NotificationCommentCell: NotificationCell {

    @IBOutlet weak var textField: UILabel!
    
    override class func reusableIdentifier() -> String {
        return "NotificationCommentCell"
    }
    
    override func setItem(item: GTNotification?) {
        super.setItem(item)

        textField.text = item?.comment?.text
    }
    
    override func getActionUser() -> GTUser {
        return item!.commenter!
    }
    
    override func getActionText() -> String? {
        return "%@ commented on your graffiti:"
    }
    
    override func getActionStreamable() -> GTStreamable? {
        return item?.commentedStreamable
    }
}
