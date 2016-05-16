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
    
    var previousItem: GTUser?
    var previousItemRequest: Request?
    var item: GTUser? {
        didSet {
            setItem()
            
            previousItem = item
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
        if item?.avatar == nil {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        else if previousItem != nil && previousItem!.id != item?.id {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        
        if item?.avatar != nil {
            previousItemRequest = Alamofire.request(.GET, item!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.avatar == nil {
                        self.avatar.image = nil
                    }
                    else if response.request?.URLString == self.item!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
    }
}
