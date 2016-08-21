//
//  GenericStreamablesViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GraffiTab_iOS_SDK
import FBLikeLayout
import CHTCollectionViewWaterfallLayout
import CarbonKit
import CocoaLumberjack

enum StreamableViewType : Int {
    case Grid
    case Trending
    case SwimLane
    case ListFull
    case Mosaic
}

class GenericStreamablesViewController: BackButtonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CHTCollectionViewDelegateWaterfallLayout, StreamableDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pullToRefresh = CarbonSwipeRefresh()
    
    var selectedCell: StreamableCell? {
        didSet {
            let frameToOpenFrom = selectedCell!.thumbnail.superview?.convertRect(selectedCell!.thumbnail.frame, toView: nil)
            transitionDelegate.openingFrame = frameToOpenFrom
            transitionDelegate.animatedView = selectedCell!.thumbnail
        }
    }
    let transitionDelegate = TransitioningDelegate()
    var items = [GTStreamable]()
    var isDownloading = false
    var canLoadMore = true
    var offset = 0
    var showStaticCollection = false
    var initialLoad = false
    var cacheResponse: Bool = false
    var viewType: StreamableViewType = .Grid {
        didSet {
            if collectionView != nil {
                configureLayout()
                
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
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
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.defaultStatusBarStyle!, animated: true)
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
    
    func basicInit() {
        viewType = .Grid
    }
    
    // MARK: - ViewType-specific helpers
    
    func getNumCols() -> Int {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        let landscape = orientation == .LandscapeLeft || orientation == .LandscapeRight
        
        switch viewType {
            case .Grid, .SwimLane:
                return landscape ? 4 : 3
            case .Trending:
                return landscape ? 3 : 2
            case .ListFull:
                return 1
            case .Mosaic:
                return landscape ? 4 : 3
        }
    }
    
    func getSpacing() -> Int {
        switch viewType {
            case .Grid, .Mosaic:
                return 2
            case .Trending, .ListFull:
                return 7
            case .SwimLane:
                return 4
        }
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        switch viewType {
            case .Grid:
                return width
            case .Trending, .SwimLane:
                return 250
            case .ListFull, .Mosaic:
                return 464
        }
    }
    
    func getPadding(spacing: CGFloat) -> CGFloat {
        return spacing
    }
    
    func configureLayout() {
        var width: CGFloat
        var height: CGFloat
        let numCols = CGFloat(getNumCols())
        let spacing = CGFloat(getSpacing())
        let padding = CGFloat(getPadding(spacing))
        
        width = ((collectionView.frame.size.width - 2*padding) - CGFloat((numCols - 1)*spacing)) / CGFloat(numCols)
        height = getHeight(width)
        
        if viewType == .Mosaic {
            let layout: FBLikeLayout
            
            if !collectionView.collectionViewLayout.isKindOfClass(FBLikeLayout.classForCoder()) {
                layout = FBLikeLayout()
            }
            else {
                layout = collectionView.collectionViewLayout as! FBLikeLayout
            }
            
            layout.minimumInteritemSpacing = spacing
            layout.singleCellWidth = width
            layout.maxCellSpace = Int(spacing)
            layout.forceCellWidthForMinimumInteritemSpacing = true
            layout.fullImagePercentageOfOccurrency = 50
            collectionView.collectionViewLayout = layout
        }
        else if viewType == .Trending || viewType == .SwimLane {
            let layout: CHTCollectionViewWaterfallLayout
            
            if !collectionView.collectionViewLayout.isKindOfClass(CHTCollectionViewWaterfallLayout.classForCoder()) {
                layout = CHTCollectionViewWaterfallLayout()
            }
            else {
                layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
            }
            
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            layout.minimumInteritemSpacing = spacing
            layout.minimumColumnSpacing = spacing
            layout.columnCount = Int(numCols)
            collectionView.collectionViewLayout = layout
        }
        else {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            layout.itemSize = CGSize(width: width, height: height)
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
        }
    }
    
    // MARK: - Events
    
    func registerForEvents() {
        // SDK events.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.genericEventHandler(_:)), name: GTEvents.CommentPosted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.genericEventHandler(_:)), name: GTEvents.CommentDeleted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.avatarChangeEventHandler(_:)), name: GTEvents.UserAvatarChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.profileChangeEventHandler(_:)), name: GTEvents.UserProfileChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.deleteStreamableEventHandler(_:)), name: GTEvents.StreamableDeleted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleStreamableEventHandler(_:)), name: GTEvents.StreamableChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleStreamableEventHandler(_:)), name: GTEvents.StreamableLikesChanged, object: nil)
        
        // App events.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarClickEventHandler(_:)), name: Notifications.AppStatusBarTouched, object: nil)
    }
    
    func statusBarClickEventHandler(notification: NSNotification) {
        self.collectionView!.setContentOffset(CGPointZero, animated: true)
    }
    
    func profileChangeEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let user = notification.userInfo!["user"] as! GTUser
        for (index, streamable) in items.enumerate() {
            if streamable.user!.isEqual(user) {
                streamable.user!.softCopy(user)
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                    }, completion: nil)
            }
        }
    }
    
    func avatarChangeEventHandler(notification: NSNotification) {
        profileChangeEventHandler(notification)
    }
    
    func deleteStreamableEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let streamableId = notification.userInfo!["streamableId"] as! Int
        if let index = items.indexOf({$0.id == streamableId}) {
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
    
    func singleStreamableEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let streamable = notification.userInfo!["streamable"] as! GTStreamable
        if let index = items.indexOf(streamable) {
            items[index].softCopy(streamable)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                }, completion: nil)
        }
    }
    
    func genericEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        collectionView.reloadData()
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
        
        if !showStaticCollection {
            loadItems(isStart, offset: offset, cacheBlock: { (response) -> Void in
                self.items.removeAll()
                
                let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
                self.items.appendContentsOf(listItemsResult.items!)
                
                self.finalizeCacheLoad()
            }, successBlock: { (response) -> Void in
                if offset == 0 {
                    self.items.removeAll()
                }
                
                let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
                self.items.appendContentsOf(listItemsResult.items!)
                
                if listItemsResult.items!.count <= 0 && listItemsResult.items!.count < GTConstants.MaxItems {
                    self.canLoadMore = false
                }
                
                self.finalizeLoad()
            }) { (response) -> Void in
                self.canLoadMore = false
                
                self.finalizeLoad()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, reason: response.error.reason)
            }
        }
        else {
            self.finalizeLoad()
        }
    }
    
    func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        assert(false, "Method should be overridden by subclass.")
    }
    
    func finalizeCacheLoad() {
        collectionView.reloadData()
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
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: AppConfig.sharedInstance.theme!.navigationBarLoadingIndicatorStyle!)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: activityIndicator), animated: true)
    }
    
    func removeLoadingIndicator() {
        let reload = UIBarButtonItem(image: UIImage(named: "ic_refresh_white"), style: .Plain, target: self, action: #selector(GenericStreamablesViewController.refresh))
        self.navigationItem.setRightBarButtonItem(reload, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if viewType == .ListFull {
//            for c in collectionView.visibleCells() {
//                let cell = c as! ChannelListFullCell
//                
//                cell.setImageOffset(CGPoint(x: 0, y: computeOffsetForCell(cell)))
//            }
//        }
    }

//    func computeOffsetForCell(cell: ChannelListFullCell) -> CGFloat {
//        return ((collectionView.contentOffset.y - cell.frame.origin.y) / (cell.thumbnail.frame.size.height)) * CGFloat(cell.imageOffsetSpeed)
//    }
    
    // MARK: - UICollectionViewDelegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if viewType == .Grid || viewType == .Mosaic || viewType == .SwimLane {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableGridCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableGridCell
            
            cell.item = items[indexPath.row]
            cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
            cell.delegate = self
            cell.indexPath = indexPath
            
            return cell
        }
        else if viewType == .Trending {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableTrendingCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableTrendingCell
            
            cell.item = items[indexPath.row]
            cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
            cell.delegate = self
            cell.indexPath = indexPath
            
            return cell
        }
        else if viewType == .ListFull {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableListFullCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableListFullCell
            
            cell.item = items[indexPath.row]
            cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
            cell.delegate = self
            cell.indexPath = indexPath
            
            // Set offset accordingly.
//            cell.setImageOffset(CGPoint(x: 0, y: computeOffsetForCell(cell)))
            
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = items[indexPath.row]
        
        if viewType == .Mosaic {
            if item.asset!.state! != .COMPLETED { // Guard in case asset is not processed yet.
                return CGSizeMake(CGFloat(50), CGFloat(50))
            }
            
            return CGSizeMake(CGFloat(item.asset!.thumbnailWidth!), CGFloat(item.asset!.thumbnailHeight!))
        }
        else if viewType == .Trending || viewType == .SwimLane {
            if item.asset!.state! != .COMPLETED { // Guard in case asset is not processed yet.
                return CGSizeMake(CGFloat(50), CGFloat(50))
            }
            
            let h = max(getHeight(0), CGFloat(item.asset!.thumbnailHeight!))
            return CGSizeMake(CGFloat(item.asset!.thumbnailWidth!), h)
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        return layout.itemSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String! {
        return NSLocalizedString("controller_streamables_no_graffiti", comment: "")
    }
    
    func getEmptyDataSetDescription() -> String! {
        return NSLocalizedString("controller_streamables_no_graffiti_detail", comment: "")
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        return UIImage(named: getEmptyDataSetImageName())
        return nil
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
    
    // MARK: - StreamableDelegate
    
    func didTapLikes(streamable: GTStreamable) {
        ViewControllerUtils.showLikers(streamable, viewController: self)
    }
    
    func didTapComments(streamable: GTStreamable) {
        ViewControllerUtils.showComments(streamable, viewController: self)
    }
    
    func didTapUser(user: GTUser) {
        ViewControllerUtils.showUserProfile(user, viewController: self)
    }
    
    func didTapShare(image: UIImage?, streamable: GTStreamable) {
        Utils.shareImage(image, viewController: self)
    }
    
    func didTapThumbnail(cell: UICollectionViewCell, streamable: GTStreamable) {
        selectedCell = (cell as! StreamableCell)
        
        ViewControllerUtils.showStreamableDetails(streamable, modalPresentationStyle: .Custom, transitioningDelegate: transitionDelegate, viewController: self)
    }
    
    // MARK: - Orientation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            if self.selectedCell != nil {
                let cell = self.selectedCell!
                self.selectedCell = cell
            }
            
            self.configureLayout()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }) { (context) in
            
        }
    }
    
    // MARK: - Setup
    
    func setupCollectionView() {
        self.view.backgroundColor = AppConfig.sharedInstance.theme?.collectionBackgroundColor
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.registerNib(UINib(nibName: StreamableGridCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableGridCell.reusableIdentifier())
        collectionView.registerNib(UINib(nibName: StreamableTrendingCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableTrendingCell.reusableIdentifier())
        collectionView.registerNib(UINib(nibName: StreamableListFullCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableListFullCell.reusableIdentifier())
        
        // Setup pull to refresh.
        pullToRefresh = CarbonSwipeRefresh(scrollView: collectionView)
        pullToRefresh.setMarginTop(self.parentViewController!.isKindOfClass(UINavigationController) ? 64 : 0)
        pullToRefresh.colors = [AppConfig.sharedInstance.theme!.primaryColor!, AppConfig.sharedInstance.theme!.secondaryColor!]
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
