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

enum UserViewType : Int {
    case List
}

class GenericUsersViewController: BackButtonViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var items = [GTUser]()
    var isDownloading = false
    
    private var viewType: UserViewType = .List
    
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
    
    func basicInit() {
        viewType = .List
    }
    
    func setViewType(type: UserViewType) {
        viewType = type
        
        if collectionView != nil {
            configureLayout()
            
            collectionView.collectionViewLayout.invalidateLayout()
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
        
        loadItems(isStart, offset: offset, successBlock: { (response) -> Void in
            if offset == 0 {
                self.items.removeAll()
            }
            
            let listItemsResult = response.object as! GTListItemsResult<GTUser>
            self.items.appendContentsOf(listItemsResult.items!)
            
            self.finalizeLoad()
        }) { (response) -> Void in
            self.finalizeLoad()
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
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
        
        assert(false, "Unsupported collection view cell.")
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(hexString: "efefef")
        cell.selectedBackgroundView = cellBGView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let user = items[indexPath.row]
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = user
        
        if self.navigationController != nil {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            assert(false, "Unable to show user profile - Unknown parent.")
        }
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    func getEmptyDataSetImageName() -> String {
        return "empty_placeholder"
    }
    
    func getEmptyDataSetTitle() -> String {
        return "No users"
    }
    
    func getEmptyDataSetDescription() -> String {
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
    
    // MARK: - Setup
    
    func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        
        collectionView.registerNib(UINib(nibName: UserListCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: UserListCell.reusableIdentifier())
    }
}
