//
//  HomeViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CarbonKit

class HomeViewController: BackButtonViewController, CarbonTabSwipeNavigationDelegate {

    @IBOutlet weak var createBtn: UIButton!
    
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    var tabs: [AnyObject]?
    var titles: [AnyObject]?
    var controllers: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCarbonKit()
        setupButtons()
        
        configureTabBasedViews(0)
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
        print("PROFILE")
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
