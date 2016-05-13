//
//  StreamableGridCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class StreamableGridCell: StreamableCell {

    override class func reusableIdentifier() -> String {
        return "StreamableGridCell"
    }
    
    override func thumbnailFullyLoaded() -> Bool {
        return false
    }
}
