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

enum StreamableViewType : Int {
    case Grid
    case Trending
    case ListFull
    case Mosaic
}

class GenericStreamablesViewController: BackButtonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, CHTCollectionViewDelegateWaterfallLayout, StreamableDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var items = [GTStreamable]()
    let colorPallete = ["5d6971", "4a545a", "6d7b84", "4a545a", "505b61", "637078", "5f6b73"]
    var isDownloading = false
    var showStaticCollection = false
    
    private var viewType: StreamableViewType = .Grid
    
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
        
        loadItems(true, offset: 0)
    }
    
    override func viewDidLayoutSubviews() {
        configureLayout()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Can be called from the Empty data set buttons.
//    func onClickCreateChannel() {
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CreateChannelViewController")
//        
//        self.presentViewController(vc!, animated: true, completion: nil)
//    }
    
    // Can be called from the Empty data set buttons.
//    func onClickViewTrending() {
//        var nav = self.navigationController
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TrendingViewController") as! TrendingViewController
//        
//        if nav == nil {
//            nav = UINavigationController(rootViewController: vc)
//            self.presentViewController(nav!, animated: true, completion: nil)
//        }
//        else {
//            nav?.pushViewController(vc, animated: true)
//        }
//    }
    
    func basicInit() {
        viewType = .Grid
    }
    
    func setViewType(type: StreamableViewType) {
        viewType = type
        
        if collectionView != nil {
            configureLayout()
            
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - ViewType-specific helpers
    
    func getNumCols() -> Int {
        switch viewType {
        case .Grid:
            return 3
        case .Trending:
            return 2
        case .ListFull:
            return 1
        case .Mosaic:
            return 3
        }
    }
    
    func getSpacing() -> Int {
        switch viewType {
        case .Grid, .Mosaic:
            return 2
        case .Trending, .ListFull:
            return 7
        }
    }
    
    func getHeight(width: CGFloat) -> CGFloat {
        switch viewType {
        case .Grid:
            return width
        case .Trending:
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
            if !collectionView.collectionViewLayout.isKindOfClass(FBLikeLayout.classForCoder()) {
                let layout = FBLikeLayout()
                layout.minimumInteritemSpacing = spacing
                layout.singleCellWidth = width
                layout.maxCellSpace = Int(spacing)
                layout.forceCellWidthForMinimumInteritemSpacing = true
                layout.fullImagePercentageOfOccurrency = 50
                collectionView.collectionViewLayout = layout
                self.collectionView.reloadData()
            }
        }
        else if viewType == .Trending {
            if !collectionView.collectionViewLayout.isKindOfClass(CHTCollectionViewWaterfallLayout.classForCoder()) {
                let layout = CHTCollectionViewWaterfallLayout()
                layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
                layout.minimumInteritemSpacing = spacing
                layout.minimumColumnSpacing = spacing
                collectionView.collectionViewLayout = layout
                self.collectionView.reloadData()
            }
        }
        else {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            layout.itemSize = CGSize(width: width, height: height)
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
        }
    }
    
    // MARK: - Loading
    
    func refresh() {
        loadItems(false, offset: 0)
    }
    
    func loadItems(isStart: Bool, offset: Int) {
        if items.count <= 0 && isDownloading == false {
            if isStart {
                if loadingIndicator != nil {
                    loadingIndicator.startAnimating()
                }
            }
        }
        
        showLoadingIndicator()
        
        isDownloading = true
        
        if !showStaticCollection {
            loadItems(isStart, offset: offset, successBlock: { (response) -> Void in
                if offset == 0 {
                    self.items.removeAll()
                }
                
                let listItemsResult = response.object as! GTListItemsResult<GTStreamable>
                self.items.appendContentsOf(listItemsResult.items!)
                
                self.finalizeLoad()
            }) { (response) -> Void in
                self.finalizeLoad()
                
                DialogBuilder.showErrorAlert(response.message, title: App.Title)
            }
        }
        else {
            self.finalizeLoad()
        }
    }
    
    func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        assert(false, "Method should be overridden by subclass.")
    }
    
    func finalizeLoad() {
        removeLoadingIndicator()
        
        if loadingIndicator != nil {
            loadingIndicator.stopAnimating()
        }
        
        isDownloading = false
        
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
        if viewType == .Grid || viewType == .Mosaic {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableGridCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableGridCell
            
            cell.setItem(items[indexPath.row])
            cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
            cell.delegate = self
            
            return cell
        }
        else if viewType == .Trending {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableTrendingCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableTrendingCell
            
            cell.setItem(items[indexPath.row])
            cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
            cell.delegate = self
            
            return cell
        }
        else if viewType == .ListFull {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableListFullCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableListFullCell
            
            cell.setItem(items[indexPath.row])
            cell.delegate = self
            
            // Set offset accordingly.
//            cell.setImageOffset(CGPoint(x: 0, y: computeOffsetForCell(cell)))
            
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
        
//        var nav = self.navigationController
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ChannelDetailsViewController") as! ChannelDetailsViewController
//        vc.channel = items![indexPath.row]
//
//        if nav == nil {
//            nav = UINavigationController(rootViewController: vc)
//            self.presentViewController(nav!, animated: true, completion: nil)
//        }
//        else {
//            nav?.pushViewController(vc, animated: true)
//        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = items[indexPath.row]
        
        if viewType == .Mosaic {
            return CGSizeMake(CGFloat(item.asset!.thumbnailWidth!), CGFloat(item.asset!.thumbnailHeight!))
        }
        else if viewType == .Trending {
            let h = max(getHeight(0), CGFloat(item.asset!.thumbnailHeight!))
            return CGSizeMake(CGFloat(item.asset!.thumbnailWidth!), h)
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        return layout.itemSize
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String {
        return "No graffiti"
    }
    
    func getEmptyDataSetDescription() -> String {
        return "No graffiti were found over here. Please come back again."
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: getEmptyDataSetImageName())
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(hexString: "909090")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetTitle()
        
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18), NSForegroundColorAttributeName:UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = getEmptyDataSetDescription()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName:UIFont.systemFontOfSize(14), NSForegroundColorAttributeName:UIColor.lightGrayColor(), NSParagraphStyleAttributeName:paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -10
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return false
    }
    
    // MARK: - StreamableDelegate
    
    func didTapLikes(streamable: GTStreamable) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LikersViewController") as! LikersViewController
        vc.streamable = streamable
        
        if self.navigationController != nil {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show likers - Unknown parent.")
        }
    }
    
    func didTapComments(streamable: GTStreamable) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        vc.streamable = streamable
        
        if self.navigationController != nil {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show likers - Unknown parent.")
        }
    }
    
    // MARK: - Setup
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        collectionView.registerNib(UINib(nibName: StreamableGridCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableGridCell.reusableIdentifier())
        collectionView.registerNib(UINib(nibName: StreamableTrendingCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableTrendingCell.reusableIdentifier())
        collectionView.registerNib(UINib(nibName: StreamableListFullCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableListFullCell.reusableIdentifier())
    }
}
