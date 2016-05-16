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
    
    var previousItem: GTUser?
    var previousItemRequest: Request?
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
        loadAvatar()
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        if item?.avatar == nil {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        else if previousItem != nil && previousItem!.id != item?.id {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        
        if item?.avatar != nil {
            previousItemRequest = Alamofire.request(.GET, item!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.avatar == nil {
                        self.avatar.image = nil
                    }
                    else if response.request?.URLString == self.item!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
    }
}
