//
//  StreamableImageView.swift
//  GraffiTab
//
//  Created by Georgi Christov on 01/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class StreamableImageView: UIImageView {
    
    var shouldLoadFullStreamable: Bool = false
    var previousStreamable: GTStreamable?
    var previousStreamableRequest: Request?
    var streamable: GTStreamable? {
        didSet {
            loadImages()
            
            previousStreamable = streamable
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
        
    }
    
    // MARK: - Loading
    
    func loadImages() {
        if streamable?.asset == nil {
            self.image = nil
            previousStreamableRequest?.cancel()
        }
        else if previousStreamable != nil && previousStreamable!.id != streamable?.id {
            self.image = nil
            previousStreamableRequest?.cancel()
        }
        
        if streamable?.asset != nil {
            previousStreamableRequest = Alamofire.request(.GET, streamable!.asset!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value != nil ? response.result.value : nil
                    
                    let targetUrl = self.streamable != nil ? self.streamable!.asset!.thumbnail! : ""
                    self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: { (imageSet: Bool) in
                        if imageSet && self.shouldLoadFullStreamable {
                            self.loadFullStreamable()
                        }
                    })
            }
        }
    }
    
    func loadFullStreamable() {
        previousStreamableRequest = Alamofire.request(.GET, streamable!.asset!.link!)
            .responseImage { response in
                let image = response.result.value != nil ? response.result.value : nil
                
                let targetUrl = self.streamable != nil ? self.streamable!.asset!.link! : ""
                self.finishLoadingImage(response.request!.URLString, targetUrl: targetUrl, image: image, completionHandler: nil)
        }
    }
    
    func finishLoadingImage(url: String, targetUrl: String, image: UIImage?, completionHandler: ((imageSet: Bool) -> ())?) {
        if self.streamable == nil || self.streamable!.asset == nil {
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
