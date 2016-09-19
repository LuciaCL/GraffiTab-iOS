//
//  GTComment+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

enum SendStatus: String, CustomStringConvertible {
    case Sending = "models_comment_sending"
    case Failed = "models_comment_failed"
    case Sent = "models_comment_sent"
    
    var description : String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

private var statusKey: UInt8 = 0

extension GTComment {

    var status: SendStatus {
        get {
            let rawvalue = objc_getAssociatedObject(self, &statusKey)
            if rawvalue == nil {
                return .Sent
            }else{
                return SendStatus(rawValue: rawvalue as! String)!;
            }
        }
        set {
            objc_setAssociatedObject(self, &statusKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
