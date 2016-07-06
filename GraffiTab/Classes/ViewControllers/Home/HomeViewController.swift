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
import JTMaterialTransition
import CocoaLumberjack

class HomeViewController: BackButtonViewController, CarbonTabSwipeNavigationDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var createBtn: UIButton!
    
    var transition: JTMaterialTransition?
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    var tabs: [AnyObject]?
    var titles: [AnyObject]?
    var controllers: [UIViewController]?
    var badge: BBBadgeBarButtonItem?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadUnseenNotificationsCount), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        setupCarbonKit()
        setupButtons()
        setupTransition()
        
        configureTabBasedViews(0)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        loadUnseenNotificationsCount()
    }
    
    override func viewDidLayoutSubviews() {
        configureTabsSize()
    }
    
    @IBAction func onClickMenu(sender: AnyObject) {
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_menu", label: nil)
        
        let mainVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as! MenuContainerViewController
        mainVC.presentLeftMenuViewController()
    }
    
    @IBAction func onClickCreate(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing Creator")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_creator", label: nil)
        
        ViewControllerUtils.checkCameraAndPhotosPermissions { 
            let vc = UIStoryboard(name: "CreateStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CreateViewController")
            
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = self
            
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickProfile(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing user profile")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_profile", label: nil)
        
        performSegueWithIdentifier("SEGUE_PROFILE", sender: sender)
    }
    
    @IBAction func onClickNotifications(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing user notifications")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_notifications", label: nil)
        
        performSegueWithIdentifier("SEGUE_NOTIFICATIONS", sender: sender)
    }
    
    @IBAction func onClickLocations(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing user locations")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_locations", label: nil)
        
        performSegueWithIdentifier("SEGUE_LOCATIONS", sender: sender)
    }
    
    @IBAction func onClickSearch(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing search")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_search", label: nil)
        
        performSegueWithIdentifier("SEGUE_SEARCH", sender: sender)
    }
    
    @IBAction func onClickSettings(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing settings")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_settings", label: nil)
        
        performSegueWithIdentifier("SEGUE_SETTINGS", sender: sender)
    }
    
    func configureTabsSize() {
        for (index, _) in (tabs?.enumerate())! {
            carbonTabSwipeNavigation!.carbonSegmentedControl!.setWidth(self.view.frame.width / CGFloat((tabs?.count)!), forSegmentAtIndex: index)
        }
        
        carbonTabSwipeNavigation!.carbonSegmentedControl?.setNeedsDisplay()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_PROFILE" {
            let vc = segue.destinationViewController as! UserProfileViewController
            vc.user = GTMeManager.sharedInstance.loggedInUser
        }
    }
    
    // MARK: - Loading
    
    func loadUnseenNotificationsCount() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Refreshing notifications")
        
        GTMeManager.getUnseenNotificationsCount({ (response) in
            self.badge?.badgeValue = response.object.stringValue
            
            // Update menu badge.
            let mainVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as! MenuContainerViewController
            let menu = mainVC.leftMenuViewController as! MenuViewController
            menu.badgeValue = response.object.integerValue
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
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.reverse = false
        
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition?.reverse = true
        
        return transition
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
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("MostActiveUsersViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("RecentViewController"))
        
        tabs = [UIImage(named: "home")!, UIImage(named: "ic_whatshot_white")!, UIImage(named: "ic_person_white")!, UIImage(named: "ic_access_time_white")!]
        titles = ["Home", "Trending", "People", "Recent"]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: tabs, delegate: self)
        carbonTabSwipeNavigation!.insertIntoRootViewController(self)
        
        // Styling.
        let tintColor = UIColor(hexString: Colors.Main)
        carbonTabSwipeNavigation!.setIndicatorColor(tintColor)
        carbonTabSwipeNavigation!.setTabExtraWidth(30)
        
        carbonTabSwipeNavigation!.setNormalColor(UIColor.blackColor().colorWithAlphaComponent(0.2))
        carbonTabSwipeNavigation!.setSelectedColor(tintColor!, font: UIFont.boldSystemFontOfSize(14))
        
        configureTabsSize()
    }
    
    func setupButtons() {
        createBtn.backgroundColor = UIColor(hexString: Colors.Main)
        self.view.bringSubviewToFront(createBtn)
    }
    
    func setupTransition() {
        transition = JTMaterialTransition(animatedView: createBtn)
    }
}
