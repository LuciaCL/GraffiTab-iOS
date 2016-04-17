//
//  UserCollectionParallaxHeader.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire

class UserCollectionParallaxHeader: UICollectionReusableView {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    
    var item: GTUser?
    
    class func reusableIdentifier() -> String {
        return "UserCollectionParallaxHeader"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupImageViews()
    }
    
    func setItem(item: GTUser?) {
        self.item = item
        
        loadAvatar()
        loadCover()
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        avatar.image = nil
        
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item!.avatar!.link! { // Verify we're still loading the current image.
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
    
    func loadCover() {
        if item?.cover != nil {
            Alamofire.request(.GET, item!.cover!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item!.cover!.link! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.avatar,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.cover.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 2
    }
}
