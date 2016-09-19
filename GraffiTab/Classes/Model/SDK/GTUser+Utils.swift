//
//  GTUser+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

extension GTUser {

    public func getFullName() -> String {
        return firstName! + " " + lastName!
    }
    
    public func getMentionUsername() -> String {
        return String(format: "@%@", username!)
    }
    
    public func streamablesCountAsString() -> String {
        return itemsCountAsString(self.streamablesCount!)
    }
    
    public func followersCountAsString() -> String {
        return itemsCountAsString(self.followersCount!)
    }
    
    public func followingCountAsString() -> String {
        return itemsCountAsString(self.followingCount!)
    }
    
    func itemsCountAsString(count: Int) -> String {
        if count < 10000 {
            return "\(count)"
        }
        else {
            return String(format: "%dK", count / 1000)
        }
    }
    
    func aboutString(label: UILabel) -> NSAttributedString {
        var text: String = ""
        
        if about != nil {
            text += about!
        }
        if website != nil {
            text += (about != nil ? "\n\n" : "") + website!
        }
        
        let attString = NSMutableAttributedString(string: text)
        
        if about != nil {
            let range = (text as NSString).rangeOfString(about!)
            attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(label.font.pointSize), range: range)
        }
        if website != nil {
            let range = (text as NSString).rangeOfString(website!)
            attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(label.font.pointSize - 3), range: range)
        }
        
        return attString
    }
    
    func isLinkedAccount(type: GTExternalProviderType) -> Bool {
        if linkedAccounts == nil {
            return false
        }
        
        for externalProvider in linkedAccounts! {
            if externalProvider.type == type {
                return true
            }
        }
        
        return false
    }
}
