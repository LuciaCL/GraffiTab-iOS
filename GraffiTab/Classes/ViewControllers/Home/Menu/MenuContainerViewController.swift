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
        
        if DeviceType.IS_IPAD {
            self.contentViewScaleValue = 0.8
            self.contentViewInLandscapeOffsetCenterX = -100
            self.contentViewInPortraitOffsetCenterX = -100
        }
        
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController")
        self.leftMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController")
        self.backgroundImage = UIImage(named: "grafitab_login")
        self.delegate = self;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if self.presentedViewController != nil {
            return self.presentedViewController!.supportedInterfaceOrientations()
        }
        return .All
    }
    
    // MARK: - RESideMenuDelegate
    
    func sideMenu(sideMenu: RESideMenu!, willShowMenuViewController menuViewController: UIViewController!) {
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.menuStatusBarStyle!, animated: true)
    }
    
    func sideMenu(sideMenu: RESideMenu!, willHideMenuViewController menuViewController: UIViewController!) {
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.defaultStatusBarStyle!, animated: true)
    }
}
