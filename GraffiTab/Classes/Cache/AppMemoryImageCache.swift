//
//  AppMemoryImageCache.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AppMemoryImageCache: NSObject {

    static let sharedInstance = AppMemoryImageCache()
    
    var cache = NSCache()
    
    func cachedImage(url: String) -> UIImage? {
        let object = cache.objectForKey(url)
        if object != nil {
            return cache.objectForKey(url) as? UIImage
        }
        return nil
    }
    
    func cacheImage(url: String?, image: UIImage?) {
        if image != nil && url != nil {
            cache.setObject(image!, forKey: url!)
        }
    }
}
