//
//  NotificationLikeCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class NotificationLikeCell: NotificationCell {

    override class func reusableIdentifier() -> String {
        return "NotificationLikeCell"
    }
    
    override func setItem(item: GTNotification?) {
        super.setItem(item)
        
    }
    
    override func getActionUser() -> GTUser {
        return item!.liker!
    }
    
    override func getActionText() -> String? {
        return "%@ liked your graffiti."
    }
    
    override func getActionStreamable() -> GTStreamable? {
        return item?.likedStreamable
    }
}
