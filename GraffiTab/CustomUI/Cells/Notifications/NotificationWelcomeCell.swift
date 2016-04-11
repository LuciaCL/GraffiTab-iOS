//
//  NotificationWelcomeCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class NotificationWelcomeCell: NotificationCell {

    override class func reusableIdentifier() -> String {
        return "NotificationWelcomeCell"
    }
    
    override func loadAvatar() {
        avatar.image = UIImage(named: "AppIcon40x40")
    }
}
