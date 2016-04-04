//
//  BackButtonTableViewController.swift
//  MassAlert
//
//  Created by Georgi Christov on 04/02/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class BackButtonTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupTopBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup
    
    func setupTopBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
    }
}
