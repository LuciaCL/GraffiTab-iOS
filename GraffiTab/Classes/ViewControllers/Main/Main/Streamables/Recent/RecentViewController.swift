//
//  RecentViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class RecentViewController: GridStreamablesViewController {
    
    // MARK: - ViewType-specific helpers
    
    override func getNumCols() -> Int {
        return 3
    }
    
    override func getSpacing() -> Int {
        return 2
    }
    
    // MARK: - Loading
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTStreamableManager.getNewest(offset, successBlock: successBlock, failureBlock: failureBlock)
    }
}
