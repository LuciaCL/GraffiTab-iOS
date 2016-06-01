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
        if asset == nil {
            self.image = nil
            previousAssetRequest?.cancel()
        }
        else if previousAsset != nil && previousAsset!.guid != asset?.guid {
            self.image = nil
            previousAssetRequest?.cancel()
        }
        
        if asset != nil {
            previousAssetRequest = Alamofire.request(.GET, asset!.thumbnail!)
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
            
            if completionHandler != nil {
                completionHandler!(imageSet: true)
            }
        }
    }
}
