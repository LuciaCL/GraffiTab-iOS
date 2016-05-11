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

protocol StreamableDelegate {
    
    func didTapLikes(streamable: GTStreamable)
    func didTapComments(streamable: GTStreamable)
}

class StreamableCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var delegate: StreamableDelegate?
    var item: GTStreamable? {
        didSet {
            setItem()
        }
    }
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    func setItem() {
        loadImage()
        loadAvatar()
    }
    
    func getStreamableImageUrl() -> String {
        return item!.asset!.thumbnail!
    }
    
    @IBAction func onClickLikers(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapLikes(item!)
        }
    }
    
    @IBAction func onClickComments(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapComments(item!)
        }
    }
    
    @IBAction func onClickLike(sender: AnyObject) {
        
    }
    
    // MARK: - Loading
    
    func loadImage() {
        thumbnail.image = nil
        
        Alamofire.request(.GET, getStreamableImageUrl())
            .responseImage { response in
                let image = response.result.value
                
                if self.item!.asset == nil {
                    return
                }
                
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
            avatar.image = nil
            
            if item?.user?.avatar != nil {
                Alamofire.request(.GET, (item?.user!.avatar?.thumbnail)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if self.item!.user!.avatar == nil {
                            return
                        }
                        
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
        }
    }
}
