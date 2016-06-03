//
//  AssetImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 01/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class AssetImageView: UIImageView {
    
    var shouldLoadFullAsset: Bool = false
    var previousAsset: GTAsset?
    var previousAssetRequest: Request?
    var asset: GTAsset? {
        didSet {
            loadImages()
            
            previousAsset = asset
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
    
    func basicInit() {
        
    }
    
    // MARK: - Loading
    
    func loadImages() {
        let fetchRemotely = {
            // Images have not been cached yet, so fetch them from the web or the internal Alamofire cache.
            self.previousAssetRequest = Alamofire.request(.GET, self.asset!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value != nil ? response.result.value : nil
                    
                    let targetUrl = self.asset != nil ? self.asset!.thumbnail! : ""
                    self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: { (imageSet: Bool) in
                        if imageSet && self.shouldLoadFullAsset {
                            self.loadFullAsset()
                        }
                    })
            }
        }
        
        if asset == nil {
            self.image = nil
            previousAssetRequest?.cancel()
        }
        else if previousAsset != nil && previousAsset!.guid != asset?.guid {
            self.image = nil
            previousAssetRequest?.cancel()
        }
        
        if asset != nil {
            // 1. Check memory cache first.
            let cachedThumbnailImage = AppMemoryImageCache.sharedInstance.cachedImage(asset!.thumbnail!)
            let cachedFullImage = AppMemoryImageCache.sharedInstance.cachedImage(asset!.link!)
            if cachedFullImage != nil {
                self.image = cachedFullImage
            }
            else if cachedThumbnailImage != nil {
                self.image = cachedThumbnailImage
                
                if shouldLoadFullAsset { // At this point we have no cached full image but we want to display a full image, so show thumbnail and fetch full image remotely and add it to cache.
                    fetchRemotely()
                }
            }
            else {
                // 2. Images have not been cached yet, so fetch them from the web or the internal Alamofire cache.
                fetchRemotely()
            }
        }
    }
    
    func loadFullAsset() {
        previousAssetRequest = Alamofire.request(.GET, asset!.link!)
            .responseImage { response in
                let image = response.result.value != nil ? response.result.value : nil
                
                let targetUrl = self.asset != nil ? self.asset!.link! : ""
                self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: nil)
        }
    }
    
    func finishLoadingImage(url: String, targetUrl: String, image: UIImage?, completionHandler: ((imageSet: Bool) -> ())?) {
        if self.asset == nil {
            self.image = nil
            
            if completionHandler != nil {
                completionHandler!(imageSet: false)
            }
        }
        else if url == targetUrl { // Verify we're still loading the current image.
            self.image = image
            
            // Add image to cache.
            AppMemoryImageCache.sharedInstance.cacheImage(url, image: image)
            
            if completionHandler != nil {
                completionHandler!(imageSet: true)
            }
        }
    }
}
