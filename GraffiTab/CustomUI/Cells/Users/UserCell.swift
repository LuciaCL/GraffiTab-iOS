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
    
    @IBOutlet weak var avatar: UIImageView!
    
    var item: GTUser?
    
    class func reusableIdentifier() -> String {
        return "UserCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupImageViews()
    }
    
    func setItem(item: GTUser?) {
        self.item = item
        
        loadAvatar()
    }
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
        else {
            avatar.image = getClearAvatarImage()
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        avatar.layer.cornerRadius = 5
    }
}
