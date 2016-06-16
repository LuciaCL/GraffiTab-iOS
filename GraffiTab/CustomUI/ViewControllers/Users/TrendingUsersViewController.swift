//
//  TrendingUsersViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class TrendingUsersViewController: GenericUsersViewController {

    override func basicInit() {
        super.basicInit()
        
        self.viewType = .Trending
    }
}
