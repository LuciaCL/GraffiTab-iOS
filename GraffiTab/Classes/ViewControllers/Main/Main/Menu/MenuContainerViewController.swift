//
//  MenuContainerViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import RESideMenu

class MenuContainerViewController: RESideMenu, RESideMenuDelegate {

    override func awakeFromNib() {
        self.menuPreferredStatusBarStyle = .LightContent;
        self.contentViewShadowColor = UIColor.blackColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 12;
        self.contentViewShadowEnabled = true;
        
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController")
        self.leftMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController")
        self.backgroundImage = UIImage(named: "grafitab_login")
        self.delegate = self;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - RESideMenuDelegate
    
    func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        print("SHOWING MENU")
    }
}