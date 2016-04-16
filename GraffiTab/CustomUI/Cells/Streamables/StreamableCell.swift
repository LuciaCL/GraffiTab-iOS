//
//  StreamableCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import AlamofireImage

class StreamableCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var item: GTStreamable?
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupImageViews()
    }
    
    func setItem(item: GTStreamable?) {
        self.item = item
        
        loadImage()
        loadAvatar()
    }
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
    }
    
    func getStreamableImageUrl() -> String {
        return item!.asset!.thumbnail!
    }
    
    // MARK: - Loading
    
    func loadImage() {
        thumbnail.image = nil
        
        Alamofire.request(.GET, getStreamableImageUrl())
            .responseImage { response in
                let image = response.result.value
                
                if response.request?.URLString == self.getStreamableImageUrl() { // Verify we're still loading the current image.
                    UIView.transitionWithView(self.thumbnail,
                        duration: App.ImageAnimationDuration,
                        options: UIViewAnimationOptions.TransitionCrossDissolve,
                        animations: {
                            self.thumbnail.image = image
                        },
                        completion: nil)
                }
        }
    }
    
    func loadAvatar() {
        if avatar != nil {
            if item?.user?.avatar != nil {
                avatar.image = nil
                
                Alamofire.request(.GET, (item?.user!.avatar?.thumbnail)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if response.request?.URLString == self.item?.user!.avatar?.thumbnail! { // Verify we're still loading the current image.
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
            else {
                avatar.image = getClearAvatarImage()
            }
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        if avatar != nil {
            avatar.layer.cornerRadius = 5
        }
    }
}
