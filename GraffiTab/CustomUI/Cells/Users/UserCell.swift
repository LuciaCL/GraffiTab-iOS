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
    
    var item: GTUser? {
        didSet {
            setItem()
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
        avatar.image = nil
        
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.avatar == nil {
                        return
                    }
                    
                    if response.request?.URLString == self.item!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.avatar,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.avatar.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
}
