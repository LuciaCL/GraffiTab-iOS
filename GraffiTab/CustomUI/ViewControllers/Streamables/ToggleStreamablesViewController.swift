//
//  ToggleStreamablesViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class ToggleStreamablesViewController: GenericStreamablesViewController {
    
    override func basicInit() {
        super.basicInit()
        
        self.viewType = .Grid
    }
    
    func onClickToggle() {
        if viewType == .Grid {
            self.viewType = .ListFull
        }
        else {
            self.viewType = .Grid
        }
        
        Utils.runWithDelay(0.01) {
            self.collectionView.reloadData()
        }
    }
    
    override func removeLoadingIndicator() {
        let toggle = UIBarButtonItem(image: UIImage(named: "ic_view_list_white"), style: .Plain, target: self, action: #selector(onClickToggle))
        self.navigationItem.setRightBarButtonItem(toggle, animated: true)
    }
}
