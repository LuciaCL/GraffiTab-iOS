//
//  ClusterViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ClusterViewController: GridStreamablesViewController {

    // MARK: - Init
    
    override func basicInit() {
        showStaticCollection = true
        print("HERE")
        super.basicInit()
    }
    
    // MARK: - ViewType-specific helpers
    
    override func getNumCols() -> Int {
        return 3
    }
    
    override func getSpacing() -> Int {
        return 2
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // МАРК: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "\(items.count) around"
    }
}
