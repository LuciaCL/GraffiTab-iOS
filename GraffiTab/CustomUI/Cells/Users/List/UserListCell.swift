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
    @IBOutlet weak var followBtn: UIButton!
    
    override class func reusableIdentifier() -> String {
        return "UserListCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButtons()
    }
    
    override func setItem(item: GTUser?) {
        super.setItem(item)
        
        if item!.followedByCurrentUser! {
            self.followBtn.layer.borderColor = UIColor(hexString: Colors.Orange)?.CGColor
            self.followBtn.backgroundColor = UIColor(hexString: Colors.Orange)
            self.followBtn.tintColor = UIColor.whiteColor()
            self.followBtn.setTitle("Following", forState: .Normal)
        }
        else {
            self.followBtn.layer.borderColor = UIColor(hexString: Colors.Main)?.CGColor
            self.followBtn.backgroundColor = UIColor.clearColor()
            self.followBtn.tintColor = UIColor(hexString: Colors.Main)
            self.followBtn.setTitle("Follow", forState: .Normal)
        }
        
        self.followBtn.hidden = item?.id == GTSettings.sharedInstance.user?.id
        
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        followBtn.layer.borderWidth = 1;
        followBtn.layer.cornerRadius = 3;
    }
}
