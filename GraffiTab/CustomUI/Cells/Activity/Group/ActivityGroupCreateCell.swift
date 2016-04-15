//
//  ActivityGroupCreateCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK

class ActivityGroupCreateCell: ActivityGroupCell {

    override class func reusableIdentifier() -> String {
        return "ActivityGroupCreateCell"
    }
    
    override func getActionText() -> NSAttributedString? {
        let targetText = String(format: "%li graffiti", item!.activities!.count)
        let text = String(format: "%@ created %@.", item!.user!.getFullName(), targetText)
        
        let attString = NSMutableAttributedString(string: text)
        var range = (text as NSString).rangeOfString(item!.user!.getFullName())
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        range = (text as NSString).rangeOfString(targetText)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(notificationField.font.pointSize), range: range)
        
        return attString
    }
    
    // MARK: - Loading
    
    override func loadImageForCollectionIndex(index: Int, view: UIImageView) {
        let streamable = item!.activities![index].createdStreamable
        
        Alamofire.request(.GET, streamable!.asset!.thumbnail!)
            .responseImage { response in
                let image = response.result.value
                
                if response.request?.URLString == streamable!.asset!.thumbnail! { // Verify we're still loading the current image.
                    view.image = image
                }
        }
    }
}
