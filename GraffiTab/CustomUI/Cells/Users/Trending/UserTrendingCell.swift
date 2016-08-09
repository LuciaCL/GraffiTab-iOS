//
//  UserTrendingCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import AlamofireImage
import JTMaterialSpinner

class UserTrendingCell: UserCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var loadingIndicator: JTMaterialSpinner!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var noItemsLbl: UILabel!
    
    static var cache = NSCache()
    
    var items = [GTStreamable]()
    var previousUserStreamablesRequest: Request?
    
    override class func reusableIdentifier() -> String {
        return "UserTrendingCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButtons()
        setupCollectionView()
        setupImageViews()
        setupLoadingIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Utils.applyShadowEffectToCellView(self)
        
        configureLayout()
    }
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
        
        setStats()
        
        loadStreamables()
    }
    
    func setStats() {
        if item!.followedByCurrentUser! {
            self.followBtn.layer.borderColor = UIColor(hexString: Colors.Green)?.CGColor
            self.followBtn.backgroundColor = UIColor(hexString: Colors.Green)
            self.followBtn.setImage(UIImage(named: "ic_action_unfollow"), forState: .Normal)
            self.followBtn.tintColor = UIColor.whiteColor()
        }
        else {
            self.followBtn.layer.borderColor = UIColor(hexString: Colors.Main)?.CGColor
            self.followBtn.backgroundColor = UIColor.clearColor()
            self.followBtn.setImage(UIImage(named: "ic_action_follow"), forState: .Normal)
            self.followBtn.tintColor = UIColor(hexString: Colors.Main)
        }
        
        self.followBtn.hidden = item?.id == GTMeManager.sharedInstance.loggedInUser?.id
    }
    
    override func onClickFollow(sender: AnyObject) {
        if item!.followedByCurrentUser! { // Unfollow.
            GTUserManager.unfollow(item!.id!, successBlock: { (response) in
                
                }, failureBlock: { (response) in
                    
            })
        }
        else { // Follow.
            GTUserManager.follow(item!.id!, successBlock: { (response) in
                
                }, failureBlock: { (response) in
                    
            })
        }
        
        item?.followedByCurrentUser = !item!.followedByCurrentUser!
        
        setStats()
    }
    
    // MARK: - ViewType-specific helpers
    
    func getSpacing() -> Int {
        return 2
    }
    
    func getNumCols() -> Int {
        return 3
    }
    
    func getPadding(spacing: CGFloat) -> CGFloat {
        return spacing
    }
    
    func configureLayout() {
        var width: CGFloat
        var height: CGFloat
        let spacing = CGFloat(getSpacing())
        let padding = CGFloat(getPadding(spacing))
        let numCols = CGFloat(getNumCols())
        
        width = ((collectionView.frame.size.width - 2*padding) - CGFloat((numCols - 1)*spacing)) / CGFloat(numCols)
        height = (collectionView.frame.size.height - 2*padding)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    // MARK: - Loading
    
    func loadStreamables() {
        noItemsLbl.hidden = true
        self.items.removeAll()
        
        if previousItem != nil && previousItem!.id != item?.id {
            loadingIndicator?.beginRefreshing()
            previousUserStreamablesRequest?.cancel()
        }
        
        // 1. Check memory cache first.
        let cachedItems = UserTrendingCell.cache.objectForKey(item!.id!)
        if cachedItems != nil {
            let itemsResult = cachedItems as! GTListItemsResult<GTStreamable>
            self.items.appendContentsOf(itemsResult.items!)
            finishLoadingStreamables()
        }
        else {
            loadingIndicator?.beginRefreshing()
            
            // 2. Streamables have not been cached yet, so fetch them from the web or the internal Alamofire cache.
            previousUserStreamablesRequest = GTUserManager.getUserStreamables(item!.id!, offset: 0, limit: 6, cacheResponse: true, cacheBlock: { (response) in
                self.items.removeAll()
                
                if response.url.containsString("users/\(self.item!.id!)/") {
                    let itemsResult = response.object as! GTListItemsResult<GTStreamable>
                    self.items.appendContentsOf(itemsResult.items!)
                }
                
                self.finishLoadingStreamables()
            }, successBlock: { (response) in
                self.items.removeAll()
                
                if response.url.containsString("users/\(self.item!.id!)/") {
                    let itemsResult = response.object as! GTListItemsResult<GTStreamable>
                    UserTrendingCell.cache.setObject(itemsResult, forKey: self.item!.id!)
                    self.items.appendContentsOf(itemsResult.items!)
                }
                
                self.finishLoadingStreamables()
            }, failureBlock: { (response) in
                self.finishLoadingStreamables()
            })
        }
        
        collectionView.reloadData()
    }
    
    func finishLoadingStreamables() {
        loadingIndicator?.endRefreshing()
        collectionView.reloadData()
        noItemsLbl.hidden = items.count > 0
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StreamableGridCell.reusableIdentifier(), forIndexPath: indexPath) as! StreamableGridCell
        
        cell.item = items[indexPath.row]
        cell.thumbnail.backgroundColor = UIColor(hexString: colorPallete[indexPath.row % colorPallete.count])
        cell.indexPath = indexPath
        
        return cell
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        followBtn.layer.borderWidth = 1;
        followBtn.layer.cornerRadius = 5;
    }
    
    func setupImageViews() {
        avatar.shouldLoadFullAsset = true
    }
    
    func setupCollectionView() {
        collectionView.registerNib(UINib(nibName: StreamableGridCell.reusableIdentifier(), bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: StreamableGridCell.reusableIdentifier())
    }
    
    func setupLoadingIndicator() {
        loadingIndicator.circleLayer.lineWidth = 2.5
        loadingIndicator.circleLayer.strokeColor = UIColor(hexString: Colors.Main)?.CGColor
    }
}
