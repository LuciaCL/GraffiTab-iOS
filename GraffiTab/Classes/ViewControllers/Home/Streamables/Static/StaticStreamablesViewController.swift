//
//  StaticStreamablesViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 02/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class StaticStreamablesViewController: ToggleStreamablesViewController {
    
    // MARK: - Init
    
    override func basicInit() {
        showStaticCollection = true
        
        super.basicInit()
    }
    
    // МАРК: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "\(items.count) graffiti"
    }
}
