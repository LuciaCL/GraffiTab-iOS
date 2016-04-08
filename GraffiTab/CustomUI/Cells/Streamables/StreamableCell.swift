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

class StreamableCell: UICollectionViewCell {
    
    @IBOutlet var thumbnail: UIImageView!
    
    var item: GTStreamable?
    
    class func reusableIdentifier() -> String {
        return "StreamableCell"
    }
    
    func setItem(item: GTStreamable?) {
        self.item = item
        
        loadImage()
    }
    
    // MARK: - Loading
    
    func loadImage() {
        if item?.asset != nil {
            Alamofire.request(.GET, (item?.asset?.link)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item?.asset?.link { // Verify we're still loading the current image.
                        self.thumbnail.image = image
                    }
                }
        }
        else {
            thumbnail.image = nil
        }
    }
}
