//
//  CommentCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var avatar: AvatarImageView!
    
    var item: GTComment?
    
    class func reusableIdentifier() -> String {
        return "CommentCell"
    }
    
    func setItem(item: GTComment?) {
        self.item = item
        
        // Setup labels.
        let name = String(format: "%@ %@", item!.user!.getFullName(), item!.user!.getMentionUsername())
        let attString = NSMutableAttributedString(string: name)
        let range = (name as NSString).rangeOfString(item!.user!.getMentionUsername())
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(nameLbl.font.pointSize - 2), range: range)
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
        self.nameLbl.attributedText = attString
        
        textLbl.text = item!.text
        dateLbl.text = DateUtils.notificationTimePassedSinceDate((item?.createdOn)!);
        
        loadAvatar()
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        avatar.image = nil
        
        if item!.user!.avatar != nil {
            Alamofire.request(.GET, item!.user!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.user!.avatar == nil {
                        return
                    }
                    
                    if response.request?.URLString == self.item!.user!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.avatar,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.avatar.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
}
