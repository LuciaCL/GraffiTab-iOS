//
//  GenericUsersViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import GraffiTab_iOS_SDK
import CarbonKit
import CocoaLumberjack

enum UserViewType : Int {
    case List
    case Trending
}

class GenericUsersViewController: BackButtonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var pullToRefresh = CarbonSwipeRefresh()
    
    var items = [GTUser]()
    var isDownloading = false
    var canLoadMore = true
    var offset = 0
    var initialLoad = false
    var showStaticCollection = false
    var viewType: UserViewType = .List {
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
        
        if self.navigationController != nil && self.navigationController!.navigationBarHidden {
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
    
    func basicInit() {
        viewType = .List
    }
    
    // MARK: - ViewType-specific helpers
    
    func getNumCols() -> Int {
        switch viewType {
        case .List, .Trending:
            return 1
        }
    }
    
    func getSpacing() -> Int {
        switch viewType {
            case .List:
                return 0
            case .Trending:
                return 10
        }
        
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        switch viewType {
            case .List:
                return 54
            case .Trending:
                return 230
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
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    // MARK: - Events
    
    func registerForEvents() {
        // SDK events.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleUserEventHandler(_:)), name: GTEvents.UserAvatarChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleUserEventHandler(_:)), name: GTEvents.UserProfileChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleUserEventHandler(_:)), name: GTEvents.UserFollowersChanged, object: nil)
        
        // App events.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.statusBarClickEventHandler(_:)), name: Notifications.AppStatusBarTouched, object: nil)
    }
    
    func statusBarClickEventHandler(notification: NSNotification) {
        self.collectionView!.setContentOffset(CGPointZero, animated: true)
    }
    
    func singleUserEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let user = notification.userInfo!["user"] as! GTUser
        if let index = items.indexOf(user) {
            items[index].softCopy(user)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
                }, completion: nil)
        }
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
                
                let listItemsResult = response.object as! GTListItemsResult<GTUser>
                self.items.appendContentsOf(listItemsResult.items!)
                
                self.finalizeCacheLoad()
                }, successBlock: { (response) -> Void in
                    if offset == 0 {
                        self.items.removeAll()
                    }
                    
                    let listItemsResult = response.object as! GTListItemsResult<GTUser>
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(UserListCell.reusableIdentifier(), forIndexPath: indexPath) as! UserListCell
            
            cell.item = items[indexPath.row]
            
            return cell
        }
        else if viewType == .Trending {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(UserTrendingCell.reusableIdentifier(), forIndexPath: indexPath) as! UserTrendingCell
            
            cell.item = items[indexPath.row]
            
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
        
        let user = items[indexPath.row]
        
        ViewControllerUtils.showUserProfile(user, viewController: self)
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String! {
        return "No users"
    }
    
    func getEmptyDataSetDescription() -> String! {
        return "No users were found. Please come back again."
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
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.registerNib(UINib(nibName: UserListCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: UserListCell.reusableIdentifier())
        collectionView.registerNib(UINib(nibName: UserTrendingCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: UserTrendingCell.reusableIdentifier())
        
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
