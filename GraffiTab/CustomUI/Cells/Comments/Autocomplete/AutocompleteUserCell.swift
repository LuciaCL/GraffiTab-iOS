//
//  AutocompleteUserCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire

class AutocompleteUserCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    
    var item: GTUser? {
        didSet {
            setItem()
        }
    }
    
    class func reusableIdentifier() -> String {
        return "AutocompleteUserCell"
    }
    
    func setItem() {
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
        
        loadAvatar()
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        avatar.image = nil
        
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.avatar == nil {
                        return
                    }
                    
                    if response.request?.URLString == self.item!.avatar!.thumbnail! { // Verify we're still loading the current image.
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
