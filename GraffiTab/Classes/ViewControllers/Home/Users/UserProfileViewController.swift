//
//  UserProfileViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 14/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CSStickyHeaderFlowLayout

class UserProfileViewController: ListFullStreamablesViewController, UserHeaderDelegate {

    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var imageType: ImageType?
    var header: UserCollectionParallaxHeader?
    var titleView: UILabel?
    var user: GTUser?
    var layout : CSStickyHeaderFlowLayout? {
        return self.collectionView?.collectionViewLayout as? CSStickyHeaderFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        setupNavigationBar()
        
        loadData()
        loadUserProfile()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 405)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickEdit(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        var followers = user?.followersCount != nil ? user?.followersCount : 0
        
        if user!.followedByCurrentUser! { // Unfollow.
            followers = followers! - 1
            if followers < 0 {
                followers = 0
            }
            
            GTUserManager.unfollow(user!.id!, successBlock: { (response) in
                self.user = response.object as? GTUser
                self.header?.item = self.user
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Follow.
            followers = followers! + 1
            
            GTUserManager.follow(user!.id!, successBlock: { (response) in
                self.user = response.object as? GTUser
                self.header?.item = self.user
            }, failureBlock: { (response) in
                    
            })
        }
        
        // Update UI.
        user?.followedByCurrentUser = !user!.followedByCurrentUser!
        user?.followersCount = followers
        header?.item = user
        
        loadData()
    }
    
    func onClickBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func isMe() -> Bool {
        return user?.id == GTSettings.sharedInstance.user!.id
    }
    
    // MARK: - Images
    
    override func didChooseImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            self.header?.item = GTSettings.sharedInstance.user
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert("Your avatar has been changed!", title: App.Title)
            }
        }
        let coverSuccessBlock = {
            self.view.hideActivityView()
            
            self.header?.item = GTSettings.sharedInstance.user
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert("Your cover has been changed!", title: App.Title)
            }
        }
        
        if image != nil { // Saving a new image.
            if imageType == .Avatar {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editAvatar(image!, successBlock: { (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editCover(image!, successBlock: { (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
        }
        else { // Removing an image.
            if imageType == .Avatar {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteAvatar({ (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteCover({ (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
        }
    }
    
    override func cropAspectRatio() -> CGSize {
        let width = CGFloat(imageType == .Avatar ? 300 : 1024);
        let height = imageType == .Avatar ? width : 768;
        
        return CGSizeMake(width, width / (width / height))
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_FOLLOWERS" {
            let vc = segue.destinationViewController as! FollowersViewController
            vc.user = user
        }
        else if segue.identifier == "SEGUE_FOLLOWING" {
            let vc = segue.destinationViewController as! FollowingViewController
            vc.user = user
        }
        else if segue.identifier == "SEGUE_STREAMABLES" {
            let vc = segue.destinationViewController as! UserStreamablesViewController
            vc.user = user
        }
        else if segue.identifier == "SEGUE_LIKES" {
            let vc = segue.destinationViewController as! UserLikedStreamablesViewController
            vc.user = user
        }
    }
    
    // MARK: - Loading
    
    func loadData() {
        followBtn.hidden = isMe()
        
        if !isMe() {
            navigationBar.topItem?.rightBarButtonItem = nil
            navigationBar.topItem?.rightBarButtonItems = nil
        }
        
        // Set follow button.
        followBtn.setImage(UIImage(named: user!.followedByCurrentUser! ? "ic_action_unfollow" : "ic_action_follow"), forState: .Normal)
        followBtn.backgroundColor = user!.followedByCurrentUser! ? UIColor(hexString: Colors.Green) : UIColor.whiteColor()
        followBtn.tintColor = user!.followedByCurrentUser! ? UIColor.whiteColor() : UIColor(hexString: Colors.Main)
    }
    
    func loadUserProfile() {
        GTUserManager.getUserFullProfile(user!.id!, successBlock: { (response) in
            self.user = response.object as? GTUser
            self.header?.item = self.user
        }) { (response) in
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    override func loadItems(isStart: Bool, offset: Int, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getUserStreamables(user!.id!, offset: offset, successBlock: successBlock, failureBlock: failureBlock)
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        // Configure header alpha.
        let minScrollDistance = CGFloat(100)
        let maxScrollDistance = CGFloat(145)
        let scrollY = collectionView.contentOffset.y
        let distanceToTravel = maxScrollDistance - minScrollDistance
        
        let offset = maxScrollDistance - scrollY
        let alpha = (1.0 * offset) / distanceToTravel
        navigationBar.backgroundColor = UIColor(hexString: Colors.Main)?.colorWithAlphaComponent(1.0 - alpha)
        titleView!.alpha = 1.0 - alpha
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == CSStickyHeaderParallaxHeader {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier(), forIndexPath: indexPath) as? UserCollectionParallaxHeader
            
            header?.item = user
            header?.delegate = self
            
            return header!
        }
        
        assert(false, "Unsupported collection view supplementary element.")
    }
    
    // MARK: - UserHeaderDelegate
    
    func didTapAbout(user: GTUser) {
        if user.website != nil {
            Utils.openUrl(user.website!)
        }
    }
    
    func didTapCover(user: GTUser) {
        if isMe() {
            imageType = .Cover
            askForImage()
        }
    }
    
    func didTapAvatar(user: GTUser) {
        if isMe() {
            imageType = .Avatar
            askForImage()
        }
    }
    
    func didTapStreamables(user: GTUser) {
        performSegueWithIdentifier("SEGUE_STREAMABLES", sender: nil)
    }
    
    func didTapFollowers(user: GTUser) {
        performSegueWithIdentifier("SEGUE_FOLLOWERS", sender: nil)
    }
    
    func didTapFollowing(user: GTUser) {
        performSegueWithIdentifier("SEGUE_FOLLOWING", sender: nil)
    }
    
    func didTapList(user: GTUser) {
        self.viewType = .ListFull
        Utils.runWithDelay(0.01) {
            self.collectionView.reloadData()
        }
    }
    
    func didTapGrid(user: GTUser) {
        self.viewType = .Grid
        Utils.runWithDelay(0.01) {
            self.collectionView.reloadData()
        }
    }
    
    func didTapFavourites(user: GTUser) {
        performSegueWithIdentifier("SEGUE_LIKES", sender: nil)
    }
    
    func didTapMap(user: GTUser) {
        // TODO:
    }
    
    // MARK: - Orientation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.header?.carousel.reloadData()
            self.collectionView.reloadEmptyDataSet()
        }, completion: nil)
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    override func getEmptyDataSetTitle() -> String! {
        return nil
    }
    
    override func getEmptyDataSetDescription() -> String! {
        return "No graffiti"
    }
    
    override func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return nil
    }
    
    override func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        let emptySpaceOffset = self.layout!.parallaxHeaderReferenceSize.height - self.view.center.y
        return emptySpaceOffset + 30
    }
    
    override func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    // MARK: - StreamableDelegate
    
    override func didTapUser(user: GTUser) {
        
    }
    
    // MARK: - Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        pullToRefresh.setMarginTop(0)
        
        collectionView.registerNib(UINib(nibName: UserCollectionParallaxHeader.reusableIdentifier(), bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier())
    }
    
    func setupButtons() {
        followBtn.layer.cornerRadius = followBtn.frame.size.width / 2
        followBtn.layer.shadowRadius = 3.0
        followBtn.layer.shadowColor = UIColor.blackColor().CGColor;
        followBtn.layer.shadowOffset = CGSizeMake(1.6, 1.6)
        followBtn.layer.shadowOpacity = 0.5
        followBtn.layer.masksToBounds = false
    }
    
    func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.backgroundColor = .clearColor()
        navigationBar.shadowImage = UIImage()
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -14
        let backBtn = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(onClickBack))
        navigationBar.topItem?.leftBarButtonItems = [negativeSpacer, backBtn]
        
        titleView = UILabel()
        titleView!.text = user?.getFullName()
        titleView!.textColor = .whiteColor()
        titleView!.textAlignment = .Center
        titleView!.font = UIFont.boldSystemFontOfSize(17)
        titleView!.frame = CGRectMake(0, 0, self.view.frame.width - 120, 21)
        navigationBar.topItem?.titleView = titleView
        titleView!.alpha = 0.0
    }
}
