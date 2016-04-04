//
//  BackButtonViewController.swift
//  Brand2Generic
//
//  Created by Georgi Christov on 24/11/2015.
//  Copyright © 2015 Futurist Labs. All rights reserved.
//

import UIKit

class BackButtonViewController: UIViewController {

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
