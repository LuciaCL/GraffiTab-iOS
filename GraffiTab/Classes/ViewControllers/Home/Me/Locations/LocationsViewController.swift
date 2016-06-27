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
import CocoaLumberjack

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
                
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        
        registerForEvents()
        
        setupCollectionView()
        
        pullToRefresh.startRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
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
                vc.toEdit = sender as? GTLocation
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
    
    // MARK: - Events
    
    func registerForEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleLocationEventHandler(_:)), name: GTEvents.LocationChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.deleteLocationEventHandler(_:)), name: GTEvents.LocationDeleted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.locationCreatedEventHandler(_:)), name: GTEvents.LocationCreated, object: nil)
    }
    
    func singleLocationEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")

        let location = notification.userInfo!["location"] as! GTLocation
        if let index = items.indexOf(location) {
            items[index].softCopy(location)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
            }, completion: {(finished) in
                if finished {
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func deleteLocationEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let locationId = notification.userInfo!["locationId"] as! Int
        if let index = items.indexOf({$0.id == locationId}) {
            self.collectionView.performBatchUpdates({
                self.items.removeAtIndex(index)
                self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
            }, completion: {(finished) in
                if finished {
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func locationCreatedEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let location = notification.userInfo!["location"] as! GTLocation
        
        self.items.append(location)
        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.items.count - 1, inSection: 0)])
        self.collectionView.reloadData()
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
        GTMeManager.getLocations({ (response) in
            successBlock(response: response)
            self.canLoadMore = false
        }, failureBlock: failureBlock)
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
        let reload = UIBarButtonItem(image: UIImage(named: "ic_refresh_white"), style: .Plain, target: self, action: #selector(GenericStreamablesViewController.refresh))
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
        return UICollectionViewCell()
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
        
        let actionSheet = buildActionSheet("What would you like to do with this place?")
        actionSheet.addButtonWithTitle("Edit", image: UIImage(named: "ic_mode_edit_white"), type: .Default) { (sheet) in
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("location_edit", label: nil)
            
            self.performSegueWithIdentifier("SEGUE_EDIT_LOCATION", sender: location)
        }
        actionSheet.addButtonWithTitle("Copy address", image: UIImage(named: "ic_content_copy_white"), type: .Default) { (sheet) in
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("location_copy_address", label: nil)
            
            UIPasteboard.generalPasteboard().string = location.address
        }
        actionSheet.addButtonWithTitle(tracked ? "Untrack" : "Track", image: UIImage(named: tracked ? "ic_radio_button_checked_white" : "ic_radio_button_unchecked_white"), type: .Default) { (sheet) in
            if tracked {
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("location_untrack", label: nil)
                
                self.removeGeofenceForLocation(location, indexPath: indexPath)
            }
            else {
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("location_track", label: nil)
                
                self.addGeofenceForLocation(location, indexPath: indexPath)
            }
        }
        actionSheet.addButtonWithTitle("Delete", image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
            DialogBuilder.showYesNoAlert("Are you sure you want to delete this location?", title: App.Title, yesTitle: "Yes, delete it!", noTitle: "Cancel", yesAction: {
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("location_delete", label: nil)
                
                self.doDeleteLocation(location, indexPath: indexPath)
            }, noAction: {
                    
            })
        }
        actionSheet.show()
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
    
    // MARK: - Orientation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.configureLayout()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }) { (context) in
            
        }
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
