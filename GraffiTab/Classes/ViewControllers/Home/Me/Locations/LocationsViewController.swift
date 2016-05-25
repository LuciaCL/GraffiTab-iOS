//
//  LocationsViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 23/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GraffiTab_iOS_SDK
import CarbonKit

enum LocationViewType : Int {
    case List
}

class LocationsViewController: BackButtonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, LocationCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pullToRefresh = CarbonSwipeRefresh()
    
    var items = [GTLocation]()
    var isDownloading = false
    var canLoadMore = true
    var offset = 0
    var initialLoad = false
    var viewType: LocationViewType = .List {
        didSet {
            if collectionView != nil {
                configureLayout()
                
                collectionView.performBatchUpdates(nil, completion: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        basicInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupCollectionView()
        
        pullToRefresh.startRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initialLoad {
            initialLoad = true
            
            loadItems(true, offset: offset)
        }
    }
    
    override func viewDidLayoutSubviews() {
        configureLayout()
        
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func basicInit() {
        viewType = .List
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_EDIT_LOCATION" {
            let vc = segue.destinationViewController as! CreateLocationViewController
            
            if sender!.isKindOfClass(GTLocation) {
                vc.toEdit = sender as! GTLocation
            }
        }
    }
    
    // MARK: - ViewType-specific helpers
    
    func getNumCols() -> Int {
        switch viewType {
        case .List:
            return 1
        }
    }
    
    func getSpacing() -> Int {
        switch viewType {
        case .List:
            return 0
        }
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        switch viewType {
        case .List:
            return 54
        }
    }
    
    func getPadding(spacing: CGFloat) -> CGFloat {
        return 8
    }
    
    func configureLayout() {
        var width: CGFloat
        var height: CGFloat
        let numCols = CGFloat(getNumCols())
        let spacing = CGFloat(getSpacing())
        let padding = CGFloat(getPadding(spacing))
        
        width = ((collectionView.frame.size.width - 2*padding) - CGFloat((numCols - 1)*spacing)) / CGFloat(numCols)
        height = getHeight(width)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    // MARK: - Loading
    
    func refresh() {
        offset = 0
        canLoadMore = true
        
        loadItems(false, offset: offset)
    }
    
    func loadItems(isStart: Bool, offset: Int) {
        showLoadingIndicator()
        
        isDownloading = true
        
        loadItems(isStart, offset: offset, successBlock: { (response) -> Void in
            if offset == 0 {
                self.items.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTLocation>
            self.items.appendContentsOf(listItemsResult.items!)
            
            if listItemsResult.items!.count <= 0 && listItemsResult.items!.count < GTConstants.MaxItems {
                self.canLoadMore = false
            }
            
            self.finalizeLoad()
        }) { (response) -> Void in
            self.canLoadMore = false
            
            self.finalizeLoad()
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
        }
    }
    
    func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTMeManager.getLocations(successBlock, failureBlock: failureBlock)
    }
    
    func finalizeLoad() {
        pullToRefresh.endRefreshing()
        removeLoadingIndicator()
        
        isDownloading = false
        
        self.collectionView.emptyDataSetSource = self
        self.collectionView.emptyDataSetDelegate = self
        collectionView.finishInfiniteScroll()
        collectionView.reloadData()
    }
    
    func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func removeLoadingIndicator() {
        let reload = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(GenericStreamablesViewController.refresh))
        self.navigationItem.setRightBarButtonItem(reload, animated: true)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if viewType == .List {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LocationListCell.reusableIdentifier(), forIndexPath: indexPath) as! LocationListCell
            
            cell.item = items[indexPath.row]
            cell.itemPosition = indexPath
            cell.delegate = self
            cell.setTrackerVisible(GTLocationManager.manager.getRegions().contains(getRegionForLocation(cell.item!)))
            
            return cell
        }
        
        assert(false, "Unsupported collection view cell.")
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(hexString: "efefef")
        cell.selectedBackgroundView = cellBGView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let location = items[indexPath.row]
        
        ViewControllerUtils.showExplorer(location.latitude, longitude: location.longitude, viewController: self)
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String! {
        return "No locations"
    }
    
    func getEmptyDataSetDescription() -> String! {
        return "No locations were found. Please come back again."
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: getEmptyDataSetImageName())
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(hexString: "909090")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetTitle()
        
        if text == nil {
            return nil
        }
        
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetDescription()
        
        if text == nil {
            return nil
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName:UIFont.systemFontOfSize(14), NSForegroundColorAttributeName:UIColor.lightGrayColor(), NSParagraphStyleAttributeName:paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return self.parentViewController?.isKindOfClass(UINavigationController) == true ? 64 / 2 : 0
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - LocationCellDelegate
    
    func didTapOptions(location: GTLocation, indexPath: NSIndexPath) {
        let tracked = GTLocationManager.manager.getRegions().contains(getRegionForLocation(location))
        let actions = ["Edit", "Copy Address", tracked ? "Untrack" : "Track"]
        
        UIActionSheet.showInView(view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete", otherButtonTitles: actions, tapBlock: { (actionSheet, index) in
            Utils.runWithDelay(0.3, block: {
                if index == 0 { // Delete.
                    self.doDeleteLocation(location, indexPath: indexPath)
                }
                else if index == 1 { // Edit.
                    self.performSegueWithIdentifier("SEGUE_EDIT_LOCATION", sender: location)
                }
                else if index == 2 { // Copy.
                    UIPasteboard.generalPasteboard().string = location.address
                }
                else if index == 3 { // Track/untrack.
                    if tracked {
                        self.removeGeofenceForLocation(location, indexPath: indexPath)
                    }
                    else {
                        self.addGeofenceForLocation(location, indexPath: indexPath)
                    }
                }
            })
        })
    }
    
    func doDeleteLocation(location: GTLocation, indexPath: NSIndexPath) {
        removeGeofenceForLocation(location, indexPath: indexPath)
        
        self.collectionView.performBatchUpdates({
            if indexPath.row < self.items.count {
                self.items.removeAtIndex(indexPath.row)
            }
            
            self.collectionView.deleteItemsAtIndexPaths([indexPath])
        }, completion: {(finished) in
            if finished {
                self.collectionView.reloadData()
            }
        })
        
        GTMeManager.deleteLocation(location.id!, successBlock: { (response) in
            
        }, failureBlock: { (response) in
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title)
        })
    }
    
    // MARK: - Geofencing
    
    func addGeofenceForLocation(location: GTLocation, indexPath: NSIndexPath) {
        if !GTLocationManager.manager.canMonitorRegions() {
            DialogBuilder.showErrorAlert("Your device does not support geofences.", title: App.Title)
            return
        }
        
        // Initialize region to minitor.
        let region = getRegionForLocation(location)
        
        // Start monitoring region.
        GTLocationManager.manager.startMonitoringRegion(region)
        
        self.collectionView .reloadData()
    }
    
    func removeGeofenceForLocation(location: GTLocation, indexPath: NSIndexPath) {
        // Initialize region to minitor.
        let region = getRegionForLocation(location)
        
        if GTLocationManager.manager.getRegions().contains(region) {
            // Stop monitoring region.
            GTLocationManager.manager.stopMonitoringRegion(region)
            
            self.collectionView .reloadData()
        }
    }
    
    func getRegionForLocation(location: GTLocation) -> CLCircularRegion {
        let l = CLLocation(latitude: location.latitude!, longitude: location.longitude!)
        return CLCircularRegion(center: l.coordinate, radius: 250, identifier: String(format: "%li", location.id!))
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Locations"
    }
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.registerNib(UINib(nibName: LocationListCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: LocationListCell.reusableIdentifier())
        
        // Setup pull to refresh.
        pullToRefresh = CarbonSwipeRefresh(scrollView: collectionView)
        pullToRefresh.setMarginTop(self.parentViewController!.isKindOfClass(UINavigationController) ? 64 : 0)
        pullToRefresh.colors = [UIColor(hexString: Colors.Main)!, UIColor(hexString: Colors.Orange)!, UIColor(hexString: Colors.Green)!]
        self.view.addSubview(pullToRefresh)
        pullToRefresh.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        // Setup infite scroll.
        collectionView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        collectionView?.addInfiniteScrollWithHandler { [weak self] (scrollView) -> Void in
            if self!.canLoadMore && !self!.isDownloading {
                self!.offset = self!.offset + GTConstants.MaxItems
                self?.loadItems(false, offset: self!.offset)
            }
            else {
                self?.isDownloading = false
                self?.collectionView.finishInfiniteScroll()
            }
        }
    }
}
