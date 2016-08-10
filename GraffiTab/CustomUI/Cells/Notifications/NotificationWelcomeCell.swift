//
//  NotificationWelcomeCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class NotificationWelcomeCell: NotificationCell {

    @IBOutlet weak var descriptionField: UILabel!
    
    override class func reusableIdentifier() -> String {
        return "NotificationWelcomeCell"
    }
    
    override func loadAvatar() {
        avatar.image = UIImage(named: "AppIcon40x40")
    }
    
    // MARK: - Setup
    
    override func setupLabels() {
        notificationField.text = NSLocalizedString("cell_notification_welcome_title", comment: "")
        descriptionField.text = NSLocalizedString("cell_notification_welcome_description", comment: "")
    }
}
