//
//  SearchViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CarbonKit
import CocoaLumberjack

class SearchViewController: BackButtonViewController, CarbonTabSwipeNavigationDelegate, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation?
    var tabs: [AnyObject]?
    var controllers: [UIViewController]?
    var searchedHashtag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupCarbonKit()
        setupSearchBar()
        
        if searchedHashtag != nil {
            searchBar.text = searchedHashtag
            (controllers?.last as! SearchStreamablesViewController).searchQuery = searchedHashtag
            
            carbonTabSwipeNavigation?.setCurrentTabIndex(1, withAnimation: false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        configureTabsSize()
    }
    
    @IBAction func onClickCancel(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configureTabsSize() {
        for (index, _) in (tabs?.enumerate())! {
            carbonTabSwipeNavigation!.carbonSegmentedControl!.setWidth(self.view.frame.width / CGFloat((tabs?.count)!), forSegmentAtIndex: index)
        }
        
        carbonTabSwipeNavigation!.carbonSegmentedControl?.setNeedsDisplay()
    }
    
    // MARK: - CarbonKitTabSwipeDelegate
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        return controllers![Int(index)]
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Searching for: \(searchBar.text)")
        
        searchBar.resignFirstResponder()
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("search", label: searchBar.text)
        
        let vc = controllers![Int(carbonTabSwipeNavigation!.currentTabIndex)]
        if vc.isKindOfClass(SearchUsersViewController) {
            let usersVC = vc as! SearchUsersViewController
            usersVC.search(searchBar.text!)
        }
        else if vc.isKindOfClass(SearchStreamablesViewController) {
            let streamablesVC = vc as! SearchStreamablesViewController
            streamablesVC.search(searchBar.text!)
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.navigationItem.titleView = searchBar
    }
    
    func setupCarbonKit() {
        controllers = [UIViewController]()
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("SearchUsersViewController"))
        controllers?.append(self.storyboard!.instantiateViewControllerWithIdentifier("SearchStreamablesViewController"))
        
        tabs = [NSLocalizedString("controller_search_people", comment: ""), NSLocalizedString("controller_search_graffiti", comment: "")]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: tabs, delegate: self)
        carbonTabSwipeNavigation!.insertIntoRootViewController(self)
        
        // Styling.
        carbonTabSwipeNavigation!.setIndicatorColor(AppConfig.sharedInstance.theme?.tabsElementsColor)
        carbonTabSwipeNavigation!.setTabExtraWidth(30)
        carbonTabSwipeNavigation!.setNormalColor(UIColor.blackColor().colorWithAlphaComponent(0.2))
        carbonTabSwipeNavigation!.setSelectedColor(AppConfig.sharedInstance.theme!.tabsElementsColor!, font: UIFont.boldSystemFontOfSize(14))
        carbonTabSwipeNavigation!.carbonSegmentedControl?.backgroundColor = AppConfig.sharedInstance.theme?.tabsBackgroundColor
        configureTabsSize()
    }
    
    func setupSearchBar() {
        searchBar.placeholder = NSLocalizedString("controller_menu_search", comment: "")
    }
}
