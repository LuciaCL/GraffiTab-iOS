//
//  AutocompleteHashCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 11/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AutocompleteHashCell: UITableViewCell {

    @IBOutlet weak var nameField: UILabel!
    
    var item: String? {
        didSet {
            setItem()
        }
    }
    
    class func reusableIdentifier() -> String {
        return "AutocompleteHashCell"
    }
    
    func setItem() {
        // Setup labels.
        self.nameField.text = "#\(item!)"
    }
}
