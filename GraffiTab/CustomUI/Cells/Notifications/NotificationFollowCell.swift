//
//  NotificationFollowCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class NotificationFollowCell: NotificationCell {

    override class func reusableIdentifier() -> String {
        return "NotificationFollowCell"
    }
    
    override func getActionUser() -> GTUser {
        return item!.follower!
    }
    
    override func getActionText() -> String? {
        return NSLocalizedString("NOTIF_FOLLOW", comment: "")
    }
}
