//
//  AvatarImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class AvatarImageView: UIImageView {

    var shouldLoadFullAvatar: Bool = false
    var previousUser: GTUser?
    var previousUserRequest: Request?
    var user: GTUser? {
        didSet {
            loadImages()
            
            previousUser = user
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    override var image: UIImage? {
        didSet {
            basicInit()
        }
    }
    
    func basicInit() {
        if self.image == nil {
            self.image = getClearAvatarImage()
        }
        
        self.layer.cornerRadius = 5
    }
    
    // MARK: - Loading
    
    func loadImages() {
        if user?.avatar == nil {
            self.image = nil
            previousUserRequest?.cancel()
        }
        else if previousUser != nil && previousUser!.id != user?.id {
            self.image = nil
            previousUserRequest?.cancel()
        }
        
        if user?.avatar != nil {
            previousUserRequest = Alamofire.request(.GET, user!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value != nil ? response.result.value : nil
                    
                    let targetUrl = self.user != nil && self.user!.avatar!.thumbnail != nil ? self.user!.avatar!.thumbnail! : ""
                    self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: { (imageSet: Bool) in
                        if imageSet && self.shouldLoadFullAvatar {
                            self.loadFullAvatar()
                        }
                    })
            }
        }
    }
    
    func loadFullAvatar() {
        previousUserRequest = Alamofire.request(.GET, user!.avatar!.link!)
            .responseImage { response in
                let image = response.result.value != nil ? response.result.value : nil
                
                let targetUrl = self.user != nil && self.user!.avatar!.link != nil ? self.user!.avatar!.link! : ""
                self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: nil)
        }
    }
    
    func finishLoadingImage(url: String, targetUrl: String, image: UIImage?, completionHandler: ((imageSet: Bool) -> ())?) {
        if self.user == nil || self.user!.avatar == nil {
            self.image = nil
            
            if completionHandler != nil {
                completionHandler!(imageSet: false)
            }
        }
        else if url == targetUrl { // Verify we're still loading the current image.
            self.image = image
            
            if completionHandler != nil {
                completionHandler!(imageSet: true)
            }
        }
    }
    
    // MARK: - Default image loading
    
    func getClearAvatarImage() -> UIImage {
        return UIImage(named: "default_avatar")!
    }
}
