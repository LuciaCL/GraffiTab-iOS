//
//  HomeViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CarbonKit
import GraffiTab_iOS_SDK
import JTMaterialTransition
import CocoaLumberjack

class HomeViewController: BackButtonViewController, CarbonTabSwipeNavigationDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var createBtn: UIButton!
    
    var notificationsBadge = UIView()
    
    var transition: JTMaterialTransition?
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    var tabs: [AnyObject]?
    var titles: [AnyObject]?
    var controllers: [UIViewController]?
    
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
        setupBadgeViews()
        
        configureTabBasedViews(0)
        checkOnboardingSequence()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.defaultStatusBarStyle!, animated: true)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        Utils.runWithDelay(0.05) {
            self.carbonTabSwipeNavigation!.carbonTabSwipeScrollView.setNeedsLayout()
            self.carbonTabSwipeNavigation!.carbonTabSwipeScrollView.layoutIfNeeded()
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
        
        let vc = UIStoryboard(name: "CreateStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CreateViewController")
        
        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onClickProfile(sender: AnyObject?) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing user profile")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("show_profile", label: nil)
        
        performSegueWithIdentifier("SEGUE_PROFILE", sender: sender)
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
    
    @IBAction func onClickExplore(sender: AnyObject) {
        let handler = {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Showing explorer")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("show_explore", label: nil)
            
            self.performSegueWithIdentifier("SEGUE_EXPLORE", sender: sender)
        }
        
        GTPermissionsManager.manager.checkPermission(.LocationWhenInUse, controller: self, accessGrantedHandler: { 
            handler()
        }) { 
            handler()
        }
    }
    
    func configureTabsSize() {
        for (index, _) in (tabs?.enumerate())! {
            if DeviceType.IS_IPAD {
                carbonTabSwipeNavigation!.carbonSegmentedControl!.setWidth(100, forSegmentAtIndex: index)
            }
            else {
                carbonTabSwipeNavigation!.carbonSegmentedControl!.setWidth(self.view.frame.width / CGFloat((tabs?.count)!), forSegmentAtIndex: index)
            }
        }
        
        carbonTabSwipeNavigation!.carbonSegmentedControl?.setNeedsDisplay()
        
        // Configure badges.
        let parent = self.carbonTabSwipeNavigation?.carbonSegmentedControl?.segments![2]
        let center = CGPointMake(parent!.frame.width / 2, parent!.frame.height - 5)
        notificationsBadge.center = center
    }
    
    // MARK: - Onboarding
    
    func checkOnboardingSequence() {
        Utils.runWithDelay(1) {
            let user = GTMeManager.sharedInstance.loggedInUser
            
            if user?.avatar == nil {
                if !Settings.sharedInstance.promptedForAvatar! {
                    let avatarPrompt = UIStoryboard(name: "OnboardingStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("AvatarPromptViewController") as! AvatarPromptViewController
                    avatarPrompt.dismissHandler = {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    self.presentViewController(avatarPrompt, animated: true, completion: nil)
                    
                    Settings.sharedInstance.promptedForAvatar = true
                }
            }
        }
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
            let unseenCount = response.object.integerValue
            
            if unseenCount <= 0 {
                self.hideNotificationsIndicator()
            }
            else {
                if self.carbonTabSwipeNavigation?.carbonSegmentedControl?.selectedSegmentIndex != 2 { // Notifications tab is not selected, so show notification indicator.
                    self.showNotificationsIndicator()
                }
                else { // Notifications tab is selected, so refresh notifications.
                    self.refreshNotificationsScreen()
                }
            }
        }) { (response) in}
    }
    
    func showNotificationsIndicator() {
        UIView.animateWithDuration(0.5, animations: {
            self.notificationsBadge.alpha = 1.0
        }, completion: nil)
    }
    
    func hideNotificationsIndicator() {
        UIView.animateWithDuration(0.1, animations: {
            self.notificationsBadge.alpha = 0.0
        }, completion: nil)
    }
    
    func refreshNotificationsScreen() {
        let notificationsVC = self.controllers![2] as! MyNotificationsViewController
        if notificationsVC.canRefresh() {
            notificationsVC.refresh()
        }
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
        
        if index == 2 {
            if notificationsBadge.alpha > 0 { // There are notifications to be viewed.
                refreshNotificationsScreen()
            }
            
            hideNotificationsIndicator()
        }
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
        menuBtn.tintColor = UINavigationBar.appearance().tintColor
        menuBtn.addTarget(self, action: #selector(HomeViewController.onClickMenu(_:)), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuBtn)
    }
    
    func setupCarbonKit() {
        self.view.backgroundColor = AppConfig.sharedInstance.theme?.collectionBackgroundColor
        
        controllers = [UIViewController]()
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("FeedViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("TrendingViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("MyNotificationsViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("RecentViewController"))
        
        tabs = [UIImage(named: "home")!, UIImage(named: "ic_whatshot_white")!, UIImage(named: "ic_notifications_none")!, UIImage(named: "ic_access_time_white")!]
        titles = [NSLocalizedString("controller_home", comment: ""), NSLocalizedString("controller_trending", comment: ""), NSLocalizedString("controller_notifications", comment: ""), NSLocalizedString("controller_recent", comment: "")]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: tabs, delegate: self)
        carbonTabSwipeNavigation!.insertIntoRootViewController(self)
        
        // Styling.
        carbonTabSwipeNavigation!.setIndicatorColor(AppConfig.sharedInstance.theme?.tabsElementsColor)
        carbonTabSwipeNavigation!.setTabExtraWidth(30)
        carbonTabSwipeNavigation!.setNormalColor(UIColor.blackColor().colorWithAlphaComponent(0.2))
        carbonTabSwipeNavigation!.setSelectedColor(AppConfig.sharedInstance.theme!.tabsElementsColor!, font: UIFont.boldSystemFontOfSize(14))
        carbonTabSwipeNavigation!.carbonSegmentedControl?.backgroundColor = AppConfig.sharedInstance.theme?.tabsBackgroundColor
        carbonTabSwipeNavigation!.carbonTabSwipeScrollView.backgroundColor = AppConfig.sharedInstance.theme?.tabsBackgroundColor
        carbonTabSwipeNavigation!.toolbar.translucent = false
        carbonTabSwipeNavigation!.toolbar.barTintColor = AppConfig.sharedInstance.theme?.tabsBackgroundColor
        
        Utils.runWithDelay(0.1) {
            self.configureTabsSize()
        }
    }
    
    func setupButtons() {
        createBtn.backgroundColor = AppConfig.sharedInstance.theme?.primaryColor
        self.view.bringSubviewToFront(createBtn)
    }
    
    func setupTransition() {
        transition = JTMaterialTransition(animatedView: createBtn)
    }
    
    func setupBadgeViews() {
        let parent = self.carbonTabSwipeNavigation?.carbonSegmentedControl?.segments![2]
        parent?.addSubview(notificationsBadge)
        
        notificationsBadge.alpha = 0.0
        notificationsBadge.frame = CGRectMake(0, 0, 4, 4)
        notificationsBadge.backgroundColor = AppConfig.sharedInstance.theme?.primaryColor
        notificationsBadge.layer.cornerRadius = notificationsBadge.frame.size.width / 2
    }
}
