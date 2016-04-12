//
//  StreamableTrendingCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class StreamableTrendingCell: StreamableCell {

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    
    override class func reusableIdentifier() -> String {
        return "StreamableTrendingCell"
    }
    
    override func setItem(item: GTStreamable?) {
        super.setItem(item)
        
        // Setup labels.
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        let likesCount = 0
        let commentsCount = 0
        self.likesLbl.text = String(format: "%i", likesCount);
        self.commentsLbl.text = String(format: "%i", commentsCount);
    }
}
