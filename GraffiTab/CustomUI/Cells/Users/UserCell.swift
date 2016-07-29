//
//  UserCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import AlamofireImage

class UserCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: AvatarImageView!
    
    var previousItem: GTUser?
    var item: GTUser? {
        didSet {
            setItem()
            
            previousItem = item
        }
    }
    
    class func reusableIdentifier() -> String {
        return "UserCell"
    }
    
    func setItem() {
        self.avatar.asset = item!.avatar
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        
    }
}
