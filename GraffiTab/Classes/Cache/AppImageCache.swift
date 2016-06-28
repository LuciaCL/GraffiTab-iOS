//
//  AppImageCache.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import SDWebImage

class AppImageCache: NSObject {

    static let sharedInstance = AppImageCache()
    
    func queryMemoryCachedImage(url: String) -> UIImage? {
        let cache = SDImageCache.sharedImageCache()
        let object = cache.imageFromMemoryCacheForKey(url)
        return object
    }
    
    func queryDiskCachedImage(url: String, done: SDWebImageQueryCompletedBlock) -> NSOperation? {
        let diskCache = SDImageCache.sharedImageCache()
        if diskCache != nil {
            return diskCache.queryDiskCacheForKey(url, done: done)
        }
        return nil
    }
    
    func cacheImage(url: String?, image: UIImage?) {
        if image != nil && url != nil {
            let cache = SDImageCache.sharedImageCache()
            cache.storeImage(image, forKey: url)
        }
    }
    
    func clearDiskCache() {
        let cache = SDImageCache.sharedImageCache()
        cache.clearDisk()
    }
}
