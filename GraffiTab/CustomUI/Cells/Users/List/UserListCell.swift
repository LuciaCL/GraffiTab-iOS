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
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
        
        setStats()
    }
    
    func setStats() {
        if item!.followedByCurrentUser! {
            self.followBtn.layer.borderColor = AppConfig.sharedInstance.theme!.primaryColor?.CGColor
            self.followBtn.backgroundColor = AppConfig.sharedInstance.theme!.primaryColor
            self.followBtn.setImage(UIImage(named: "ic_action_unfollow"), forState: .Normal)
            self.followBtn.tintColor = UIColor.whiteColor()
        }
        else {
            self.followBtn.layer.borderColor = AppConfig.sharedInstance.theme?.primaryColor?.CGColor
            self.followBtn.backgroundColor = UIColor.clearColor()
            self.followBtn.setImage(UIImage(named: "ic_action_follow"), forState: .Normal)
            self.followBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        }
        
        self.followBtn.hidden = item?.id == GTMeManager.sharedInstance.loggedInUser?.id
    }
    
    override func onClickFollow(sender: AnyObject) {
        if item!.followedByCurrentUser! { // Unfollow.
            GTUserManager.unfollow(item!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Follow.
            GTUserManager.follow(item!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        
        item?.followedByCurrentUser = !item!.followedByCurrentUser!
        
        setStats()
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        followBtn.layer.borderWidth = 1;
        followBtn.layer.cornerRadius = 5;
    }
}
