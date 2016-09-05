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
    var previousAssetDiskRequest: NSOperation?
    var asset: GTAsset? {
        didSet {
            loadThumbnailAndCachedAsset()
            
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
    
    func loadThumbnailAndCachedAsset() {
        let fetchFromDisk = {
            // 3. No memory cache at this point, so try fetching full image from disk cache.
            self.previousAssetDiskRequest = AppImageCache.sharedInstance.queryDiskCachedImage(self.asset!.link!, done: { (cachedFullImage, type) in
                
                if self.asset == nil {
                    self.image = nil
                    self.previousAssetRequest?.cancel()
                    self.previousAssetDiskRequest?.cancel()
                    return
                }
                
                if cachedFullImage != nil {
                    // Previous full sized image was found in disk cache.
                    self.image = cachedFullImage
                }
                else {
                    let fetchRemotely = {
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
                    
                    // 4. No memory cache at this point, so try fetching thumbnail image from disk cache.
                    self.previousAssetDiskRequest = AppImageCache.sharedInstance.queryDiskCachedImage(self.asset!.thumbnail!, done: { (cachedThumbnailImage, type) in
                        
                        if self.asset == nil {
                            self.image = nil
                            self.previousAssetRequest?.cancel()
                            self.previousAssetDiskRequest?.cancel()
                            return
                        }
                        
                        if cachedThumbnailImage != nil {
                            // Previous thumbnail sized image was found in disk cache.
                            self.image = cachedThumbnailImage
                            
                            if self.shouldLoadFullAsset { // At this point we have no cached full image but we want to display a full image, so show thumbnail and fetch full image remotely and add it to cache.
                                fetchRemotely()
                            }
                        }
                        else {
                            // 5. Images have not been cached yet, so fetch them from the web.
                            fetchRemotely()
                        }
                    })
                }
            })
        }
        
        if asset == nil {
            self.image = nil
            previousAssetRequest?.cancel()
            previousAssetDiskRequest?.cancel()
        }
        else if previousAsset != nil && previousAsset!.guid != asset?.guid {
            self.image = nil
            previousAssetRequest?.cancel()
            previousAssetDiskRequest?.cancel()
        }
        
        if asset != nil {
            // 1. Check memory cache first.
            let cachedThumbnailImage = AppImageCache.sharedInstance.queryMemoryCachedImage(asset!.thumbnail!)
            let cachedFullImage = AppImageCache.sharedInstance.queryMemoryCachedImage(asset!.link!)
            if cachedFullImage != nil {
                self.image = cachedFullImage
            }
            else if cachedThumbnailImage != nil {
                self.image = cachedThumbnailImage
                
                if shouldLoadFullAsset { // At this point we have no cached full image but we want to display a full image, so show thumbnail and fetch full image remotely and add it to cache.
                    fetchFromDisk()
                }
            }
            else {
                // 2. Images have not been cached yet, so fetch them from the web or the disk cache.
                fetchFromDisk()
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
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                // Add image to cache.
                AppImageCache.sharedInstance.cacheImage(url, image: image)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                })
            })
            
            if completionHandler != nil {
                completionHandler!(imageSet: true)
            }
        }
    }
}
