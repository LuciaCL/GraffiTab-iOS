//
//  GTLocation+Asset.swift
//  GraffiTab
//
//  Created by Georgi Christov on 02/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import ObjectMapper

private var assetKey: UInt8 = 0

extension GTLocation {
    
    var asset: GTAsset {
        get {
            let currentValue = objc_getAssociatedObject(self, &assetKey)
            if currentValue == nil {
                let asset = GTAsset(Map(mappingType: .FromJSON, JSONDictionary: [:]))
                asset?.thumbnail = GoogleStaticApiUtils.getStaticMapUrl(self.latitude!, longitude: self.longitude!)
                return asset!
            }
            else{
                return currentValue as! GTAsset
            }
        }
        set {
            objc_setAssociatedObject(self, &assetKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}