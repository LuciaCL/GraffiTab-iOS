//
//  GTComment+Extra.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

enum SendStatus: String {
    case Sending = "Sending"
    case Failed = "Failed"
    case Sent = "Sent"
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
