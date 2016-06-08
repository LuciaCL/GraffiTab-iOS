//
//  DrawToolCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 30/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class DrawToolCell: UICollectionViewCell {
    
    @IBOutlet weak var toolImg: UIImageView!
    
    class func reusableIdentifier() -> String {
        return "DrawToolCell"
    }
}
