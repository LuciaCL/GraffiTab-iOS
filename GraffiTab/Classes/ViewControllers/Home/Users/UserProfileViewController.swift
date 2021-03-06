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
import AHKActionSheet
import CocoaLumberjack

class UserProfileViewController: ListFullStreamablesViewController, UserHeaderDelegate {

    @IBOutlet weak var followBtn: ProfileFollowButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let parallaxHeaderHeight = CGFloat(DeviceType.IS_IPAD ? 480 : 405)
    
    var navigationSeparator: UIView?
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
        
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, parallaxHeaderHeight)
        
        setupNavigationBar()
        setupButtons()
        
        loadData()
        loadUserProfile()
        
        Utils.runWithDelay(0.5) {
            self.checkAndAnimateFollowButton()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureStatusBarForScrollOffset()
        
        if !self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layout?.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, parallaxHeaderHeight)
    }

    @IBAction func onClickEdit(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Edit user profile")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("edit_profile", label: nil)
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfileViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func onClickFollow(sender: AnyObject) {
        var followers = user?.followersCount != nil ? user?.followersCount : 0
        
        if user!.followedByCurrentUser! { // Unfollow.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Unfollow")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("unfollow", label: nil)
            
            followers = followers! - 1
            if followers < 0 {
                followers = 0
            }
            
            GTUserManager.unfollow(user!.id!, successBlock: { (response) in
                self.user?.softCopy(response.object as! GTUser)
                self.header?.item = self.user
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Follow.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Follow")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("follow", label: nil)
            
            followers = followers! + 1
            
            GTUserManager.follow(user!.id!, successBlock: { (response) in
                self.user?.softCopy(response.object as! GTUser)
                self.header?.item = self.user
            }, failureBlock: { (response) in
                    
            })
        }
        
        // Update UI.
        user?.followedByCurrentUser = !user!.followedByCurrentUser!
        user?.followersCount = followers
        header?.item = user
        
        loadData()
        followBtn.setNeedsLayout()
        followBtn.layoutIfNeeded()
        followBtn.animateButton()
    }
    
    func onClickBack() {
        if self.navigationController?.viewControllers.count <= 1 { // We're running in a container so show a close button.
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func isMe() -> Bool {
        return user?.id == GTMeManager.sharedInstance.loggedInUser!.id
    }
    
    // MARK: - Events
    
    override func registerForEvents() {
        super.registerForEvents()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.coverChangeEventHandler(_:)), name: GTEvents.UserCoverChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.profileChangeEventHandler(_:)), name: GTEvents.UserFollowersChanged, object: nil)
    }
    
    func coverChangeEventHandler(notification: NSNotification) {
        let u = notification.userInfo!["user"] as! GTUser
        if self.user!.isEqual(u) {
            finishProfileChange(u)
        }
    }
    
    override func profileChangeEventHandler(notification: NSNotification) {
        super.profileChangeEventHandler(notification)
        
        let u = notification.userInfo!["user"] as! GTUser
        if self.user!.isEqual(u) {
            finishProfileChange(u)
        }
    }
    
    func finishProfileChange(user: GTUser) {
        let streamablesCount = self.user?.streamablesCount
        let followersCount = self.user?.followersCount
        let followingCount = self.user?.followingCount
        
        self.user?.softCopy(user)
        self.user?.streamablesCount = streamablesCount
        self.user?.followersCount = followersCount
        self.user?.followingCount = followingCount
        
        self.header?.item = self.user
        
        loadData()
    }
    
    // MARK: - Follow button animations
    
    func checkAndAnimateFollowButton() {
        if !isMe() {
            followBtn.animateButton()
        }
    }
    
    // MARK: - Images
    
    override func buildActionSheet(title: String?) -> AHKActionSheet {
        let actionSheet = super.buildActionSheet(title)
        if imageType == .Avatar {
            actionSheet.addButtonWithTitle(NSLocalizedString("controller_avatar_prompt_import_from_facebook", comment: ""), image: UIImage(named: "facebook"), type: self.user!.isLinkedAccount(.FACEBOOK) ? .Default : .Disabled) { (sheet) in
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    self.header?.item = GTMeManager.sharedInstance.loggedInUser
                    
                    Utils.runWithDelay(0.3) { () in
                        DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_avatar_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
                    }
                }, failureBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
        }
        return actionSheet
    }
    
    override func didChooseImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            self.header?.item = GTMeManager.sharedInstance.loggedInUser
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_avatar_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }
        let coverSuccessBlock = {
            self.view.hideActivityView()
            
            self.header?.item = GTMeManager.sharedInstance.loggedInUser
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_cover_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }
        
        if image != nil { // Saving a new image.
            if imageType == .Avatar {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editAvatar(image!, successBlock: { (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
            else {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editCover(image!, successBlock: { (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
        }
        else { // Removing an image.
            if imageType == .Avatar {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteAvatar({ (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
            else {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteCover({ (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
        else if segue.identifier == "SEGUE_MENTIONS" {
            let vc = segue.destinationViewController as! UserMentionsViewController
            vc.user = user
        }
    }
    
    // MARK: - Loading
    
    override func refresh() {
        loadUserProfile()
        
        super.refresh()
    }
    
    func loadData() {
        followBtn.hidden = isMe()
        
        if !isMe() {
            navigationBar.topItem?.rightBarButtonItem = nil
            navigationBar.topItem?.rightBarButtonItems = nil
        }
        
        // Set follow button.
        followBtn.styleForUser(user!)
    }
    
    func loadUserProfile() {
        GTUserManager.getUserFullProfile(user!.id!, cacheResponse: true, cacheBlock: { (response) in
            self.user?.softCopy(response.object as! GTUser)
            self.header?.item = self.user
        }, successBlock: { (response) in
            self.user?.softCopy(response.object as! GTUser)
            self.header?.item = self.user
        }) { (response) in
            DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, reason: response.error.reason)
        }
    }
    
    override func loadItems(isStart: Bool, offset: Int, cacheBlock: (response: GTResponseObject) -> Void, successBlock: (response: GTResponseObject) -> Void, failureBlock: (response: GTResponseObject) -> Void) {
        GTUserManager.getUserStreamables(user!.id!, offset: offset, cacheResponse: isStart, cacheBlock: cacheBlock, successBlock: successBlock, failureBlock: failureBlock)
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
        navigationBar.backgroundColor = AppConfig.sharedInstance.theme?.navigationBarBackgroundColor?.colorWithAlphaComponent(1.0 - alpha)
        titleView!.alpha = 1.0 - alpha
        navigationSeparator?.alpha = titleView!.alpha
        
        configureStatusBarForScrollOffset()
    }
    
    func configureStatusBarForScrollOffset() {
        let minScrollDistance = CGFloat(100)
        let scrollY = collectionView.contentOffset.y
        if scrollY > minScrollDistance {
            UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.profileStatusBarWithNavigationBarStyle!, animated: true)
            
            navigationBar.tintColor = AppConfig.sharedInstance.theme?.navigationBarProfileElementsWithNavigationBarColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfig.sharedInstance.theme!.navigationBarProfileElementsWithNavigationBarColor!]
        }
        else {
            UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.profileStatusBarStyle!, animated: true)
            
            navigationBar.tintColor = AppConfig.sharedInstance.theme?.navigationBarProfileElementsColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfig.sharedInstance.theme!.navigationBarProfileElementsColor!]
        }
        
        titleView!.textColor = navigationBar.titleTextAttributes![NSForegroundColorAttributeName] as! UIColor
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
        return UICollectionViewCell()
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
    
    func didTapTags(user: GTUser) {
        performSegueWithIdentifier("SEGUE_MENTIONS", sender: nil)
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
        return NSLocalizedString("controller_streamables_no_graffiti", comment: "")
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
        
        pullToRefresh.setMarginTop(20)
        
        collectionView.registerNib(UINib(nibName: UserCollectionParallaxHeader.reusableIdentifier(), bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: UserCollectionParallaxHeader.reusableIdentifier())
    }
    
    func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBar.backgroundColor = .clearColor()
        navigationBar.shadowImage = UIImage()
        
        navigationBar.tintColor = AppConfig.sharedInstance.theme?.navigationBarProfileElementsColor
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppConfig.sharedInstance.theme!.navigationBarProfileElementsColor!]
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -14
        let backBtn = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(onClickBack))
        navigationBar.topItem?.leftBarButtonItems = [negativeSpacer, backBtn]
        
        titleView = UILabel()
        titleView!.text = user?.getFullName()
        titleView!.textColor = navigationBar.titleTextAttributes![NSForegroundColorAttributeName] as! UIColor
        titleView!.textAlignment = .Center
        titleView!.font = UIFont.boldSystemFontOfSize(17)
        titleView!.frame = CGRectMake(0, 0, self.view.frame.width - 120, 21)
        navigationBar.topItem?.titleView = titleView
        titleView!.alpha = 0.0
        
        navigationSeparator = UIView()
        navigationSeparator?.alpha = 0
        navigationSeparator!.backgroundColor = UIColor(hexString: "#b0b0b0")
        navigationSeparator!.frame = CGRectMake(0, navigationBar.frame.height, navigationBar.frame.width, 0.5)
        navigationSeparator?.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin, .FlexibleWidth]
        navigationBar.addSubview(navigationSeparator!)
    }
    
    func setupButtons() {
        followBtn.applyMaterializeStyle()
    }
}
