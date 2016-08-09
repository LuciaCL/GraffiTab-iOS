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
import JTMaterialSpinner

protocol StreamableDelegate {
    
    func didTapLikes(streamable: GTStreamable)
    func didTapComments(streamable: GTStreamable)
    func didTapShare(image: UIImage?, streamable: GTStreamable)
    
    func didTapUser(user: GTUser)
    
    func didTapThumbnail(cell: UICollectionViewCell, streamable: GTStreamable)
}

class StreamableCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingIndicator: JTMaterialSpinner!
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var thumbnail: StreamableImageView!
    
    var pollTimer: NSTimer?
    var indexPath: NSIndexPath?
    var delegate: StreamableDelegate?
    var previousItem: GTStreamable?
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
        setupLoadingIndicator()
    }
    
    func setItem() {
        loadImage()
        loadAvatar()
        checkProcessingState()
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
            delegate?.didTapShare(thumbnail.image, streamable: item!)
        }
    }
    
    @IBAction func onClickThumbnail(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapThumbnail(self, streamable: item!)
        }
    }
    
    @IBAction func onClickLike(sender: AnyObject) {
        
    }
    
    // MARK: - Polling
    
    func checkProcessingState() {
        if item?.asset?.state != .COMPLETED {
            if loadingIndicator != nil {
                loadingIndicator.beginRefreshing()
            }
            startPollTimer()
        }
        else {
            if loadingIndicator != nil {
                loadingIndicator.endRefreshing()
            }
            stopPollTimer()
        }
    }
    
    func pollForAssetState() {
        GTAssetManager.getAssetState(item!.asset!.guid!, successBlock: { (response) in
            let responseAsset = response.object as! GTAsset
            if responseAsset.state == .COMPLETED {
                if self.loadingIndicator != nil {
                    self.loadingIndicator.endRefreshing()
                }
                self.stopPollTimer()
                self.item!.asset = responseAsset
                self.setItem()
            }
        }) { (response) in
            
        }
    }
    
    func startPollTimer() {
        stopPollTimer()
        
        pollTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(self.pollForAssetState), userInfo: nil, repeats: true)
    }
    
    func stopPollTimer() {
        if pollTimer != nil {
            pollTimer?.invalidate()
            pollTimer = nil
        }
    }
    
    // MARK: - Loading
    
    func loadImage() {
        thumbnail.asset = item!.asset
    }
    
    func loadAvatar() {
        if avatar != nil {
            avatar.asset = item!.user!.avatar
        }
    }
    
    // MARK: - Setup
    
    func setupGestureRecognizers() {
        thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickThumbnail)))
    }
    
    func setupLoadingIndicator() {
        if loadingIndicator != nil {
            loadingIndicator.circleLayer.lineWidth = 2.5
            loadingIndicator.circleLayer.strokeColor = UIColor.whiteColor().CGColor
        }
    }
}
