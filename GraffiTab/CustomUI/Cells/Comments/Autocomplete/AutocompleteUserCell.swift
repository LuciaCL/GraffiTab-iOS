//
//  AutocompleteUserCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire

class AutocompleteUserCell: UITableViewCell {

    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    
    var item: GTUser? {
        didSet {
            setItem()
        }
    }
    
    class func reusableIdentifier() -> String {
        return "AutocompleteUserCell"
    }
    
    func setItem() {
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
        
        self.avatar.user = item
    }
}
