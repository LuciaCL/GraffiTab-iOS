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
    func didTapShare(image: UIImage, streamable: GTStreamable)
    
    func didTapUser(user: GTUser)
    
    func didTapThumbnail(cell: UICollectionViewCell, streamable: GTStreamable, thumbnailImage: UIImage, isFullyLoaded: Bool)
}

class StreamableCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var delegate: StreamableDelegate?
    var previousItem: GTStreamable?
    var previousItemRequest: Request?
    var previousAvatarRequest: Request?
    var item: GTStreamable? {
        didSet {
            setItem()
            
            previousItem = item
        }
    }
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizers()
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
    
    @IBAction func onClickUser(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapUser(item!.user!)
        }
    }
    
    @IBAction func onClickShare(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapShare(thumbnail.image!, streamable: item!)
        }
    }
    
    @IBAction func onClickThumbnail(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapThumbnail(self, streamable: item!, thumbnailImage: thumbnail!.image!, isFullyLoaded: thumbnailFullyLoaded())
        }
    }
    
    @IBAction func onClickLike(sender: AnyObject) {
        
    }
    
    func thumbnailFullyLoaded() -> Bool {
        assert(false, "Must be implemented by subclasses.")
    }
    
    // MARK: - Loading
    
    func loadImage() {
        if previousItem?.id != item?.id {
            thumbnail.image = nil
            previousItemRequest?.cancel()
        }
        
        previousItemRequest = Alamofire.request(.GET, getStreamableImageUrl())
            .responseImage { response in
                let image = response.result.value
                
                if response.request?.URLString == self.getStreamableImageUrl() { // Verify we're still loading the current image.
                    self.thumbnail.image = image
                }
        }
    }
    
    func loadAvatar() {
        if avatar != nil {
            if item?.user?.avatar == nil {
                avatar.image = nil
                previousAvatarRequest?.cancel()
            }
            else if previousItem != nil && previousItem!.user?.id != item?.user?.id {
                avatar.image = nil
                previousAvatarRequest?.cancel()
            }
            
            if item?.user?.avatar != nil {
                previousAvatarRequest = Alamofire.request(.GET, (item?.user!.avatar?.thumbnail)!)
                    .responseImage { response in
                        let image = response.result.value
                        
                        if self.item!.user!.avatar == nil {
                            self.avatar.image = nil
                        }
                        else if response.request?.URLString == self.item?.user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                            self.avatar.image = image
                        }
                }
            }
        }
    }
    
    // MARK: - Setup
    
    func setupGestureRecognizers() {
        thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickThumbnail)))
    }
}
