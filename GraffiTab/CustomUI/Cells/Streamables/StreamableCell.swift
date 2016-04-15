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
        Alamofire.request(.GET, getStreamableImageUrl())
            .responseImage { response in
                let image = response.result.value
                
                if response.request?.URLString == self.getStreamableImageUrl() { // Verify we're still loading the current image.
                    self.thumbnail.image = image
                }
        }
    }
    
    func loadAvatar() {
        if avatar != nil {
            if item?.user?.avatar != nil {
                Alamofire.request(.GET, (item?.user!.avatar?.thumbnail)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if response.request?.URLString == self.item?.user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                            self.avatar.image = image
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
