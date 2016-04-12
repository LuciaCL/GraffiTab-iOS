//
//  UserListCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class UserListCell: UserCell {

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    
    override class func reusableIdentifier() -> String {
        return "UserListCell"
    }
    
    override func setItem(item: GTUser?) {
        super.setItem(item)
        
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
    }
}
