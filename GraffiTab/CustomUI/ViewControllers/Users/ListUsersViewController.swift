//
//  ListUsersViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class ListUsersViewController: GenericUsersViewController {

    override func basicInit() {
        super.basicInit()
        
        setViewType(.List)
    }
}
