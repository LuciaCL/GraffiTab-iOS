//
//  HomeViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CarbonKit
import BBBadgeBarButtonItem
import GraffiTab_iOS_SDK

class HomeViewController: BackButtonViewController, CarbonTabSwipeNavigationDelegate {

    @IBOutlet weak var createBtn: UIButton!
    
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    var tabs: [AnyObject]?
    var titles: [AnyObject]?
    var controllers: [UIViewController]?
    var badge: BBBadgeBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCarbonKit()
        setupButtons()
        
        configureTabBasedViews(0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        loadUnseenNotificationsCount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickMenu(sender: AnyObject) {
        let mainVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as! MenuContainerViewController
        mainVC.presentLeftMenuViewController()
    }
    
    @IBAction func onClickCreate(sender: AnyObject?) {
        print("CREATE")
    }
    
    @IBAction func onClickProfile(sender: AnyObject?) {
        performSegueWithIdentifier("SEGUE_PROFILE", sender: sender)
    }
    
    @IBAction func onClickNotifications(sender: AnyObject?) {
        performSegueWithIdentifier("SEGUE_NOTIFICATIONS", sender: sender)
    }
    
    @IBAction func onClickExplore(sender: AnyObject?) {
        performSegueWithIdentifier("SEGUE_EXPLORE", sender: sender)
    }
    
    @IBAction func onClickSettings(sender: AnyObject?) {
        performSegueWithIdentifier("SEGUE_SETTINGS", sender: sender)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_PROFILE" {
            let vc = segue.destinationViewController as! UserProfileViewController
            vc.user = GTSettings.sharedInstance.user
        }
    }
    
    // MARK: - Loading
    
    func loadUnseenNotificationsCount() {
        GTMeManager.getUnseenNotificationsCount({ (response) in
            self.badge?.badgeValue = response.object.stringValue
        }) { (response) in}
    }
    
    // MARK: - CarbonKitTabSwipeDelegate
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        return controllers![Int(index)]
    }
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAtIndex index: UInt) {
        configureTabBasedViews(Int(carbonTabSwipeNavigation.currentTabIndex))
    }
    
    func configureTabBasedViews(index: Int) {   
        self.title = titles![index] as? String
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        let menuBtn = TintButton.init(frame: CGRectMake(0, 0, 25, 25))
        menuBtn.setImage(UIImage(named: "ic_menu_white"), forState: .Normal)
        menuBtn.tintColor = UIColor.whiteColor()
        menuBtn.addTarget(self, action: #selector(HomeViewController.onClickMenu(_:)), forControlEvents: .TouchUpInside)
        
        badge = BBBadgeBarButtonItem.init(customUIButton: menuBtn)
        badge!.shouldHideBadgeAtZero = true
        badge!.badgeOriginX = 15
        badge!.badgeOriginY = -6
        badge!.badgeBGColor = UIColor(hexString: Colors.Orange)
        badge!.badgeTextColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = badge!
    }
    
    func setupCarbonKit() {
        controllers = [UIViewController]()
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("FeedViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("TrendingViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("NearMeViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("RecentViewController"))
        
        tabs = [UIImage(named: "home")!, UIImage(named: "ic_whatshot_white")!, UIImage(named: "ic_near_me_white")!, UIImage(named: "ic_access_time_white")!]
        titles = ["Home", "Trending", "Near me", "Recent"]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: tabs, delegate: self)
        carbonTabSwipeNavigation!.insertIntoRootViewController(self)
        
        // Styling.
        let tintColor = UIColor(hexString: Colors.Main)
        carbonTabSwipeNavigation!.setIndicatorColor(tintColor)
        carbonTabSwipeNavigation!.setTabExtraWidth(30)
        
        for (index, _) in (tabs?.enumerate())! {
            carbonTabSwipeNavigation!.carbonSegmentedControl!.setWidth(self.view.frame.width / CGFloat((tabs?.count)!), forSegmentAtIndex: index)
        }
        
        carbonTabSwipeNavigation!.setNormalColor(UIColor.blackColor().colorWithAlphaComponent(0.2))
        carbonTabSwipeNavigation!.setSelectedColor(tintColor!, font: UIFont.boldSystemFontOfSize(14))
    }
    
    func setupButtons() {
        createBtn.layer.cornerRadius = createBtn.frame.size.width / 2
        createBtn.layer.shadowRadius = 3.0
        createBtn.layer.shadowColor = UIColor.blackColor().CGColor;
        createBtn.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        createBtn.layer.shadowOpacity = 0.5
        createBtn.layer.masksToBounds = false
        createBtn.backgroundColor = UIColor(hexString: Colors.Main)
        
        self.view.bringSubviewToFront(createBtn)
    }
}
