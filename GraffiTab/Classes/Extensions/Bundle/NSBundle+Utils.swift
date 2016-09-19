//
//  NSBundle+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 05/09/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

private var languageKey: UInt8 = 0

extension NSBundle {

    class var language: String? {
        get {
            let obj = objc_getAssociatedObject(self, &languageKey)
            
            if obj != nil {
                return obj as? String
            }
            return nil
        }
        set {
            var onceToken: dispatch_once_t = 0
            dispatch_once(&onceToken) {
                object_setClass(NSBundle.mainBundle(), BundleEx.self)
            }
            
            objc_setAssociatedObject(self, &languageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class BundleEx : NSBundle {
    
    override func localizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
        if NSBundle.language != nil {
            let bundle = NSBundle(path: NSBundle.mainBundle().pathForResource(NSBundle.language, ofType: "lproj")!)
            return bundle!.localizedStringForKey(key, value: value, table: tableName)
        }
        else {
            return super.localizedStringForKey(key, value: value, table: tableName)
        }
    }
}
