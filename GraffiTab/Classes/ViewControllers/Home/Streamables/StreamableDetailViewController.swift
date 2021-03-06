//
//  StreamableDetailViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import CocoaLumberjack

class StreamableDetailViewController: BackButtonViewController, ZoomableImageViewDelegate {

    @IBOutlet weak var streamableImage: ZoomableImageView!
    @IBOutlet weak var topMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var likesContainer: UIView!
    @IBOutlet weak var commentsContainer: UIView!
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    
    var streamable: GTStreamable?
    var viewsVisible = true
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerForEvents()
        
        setupImageViews()
        setupContainers()
        
        loadData()
        loadAvatar()
        loadStreamableImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.detailsStatusBarStyle!, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Utils.runWithDelay(0.2) {
            self.showViews()
        }
    }
    
    @IBAction func onClickUser(sender: AnyObject) {
        ViewControllerUtils.showUserProfile(streamable!.user!, viewController: self)
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickMenu(sender: AnyObject) {
        let actionSheet = buildActionSheet(NSLocalizedString("controller_streamable_options_title", comment: ""))
        if isMe() {
            actionSheet.addButtonWithTitle(NSLocalizedString("other_edit", comment: ""), image: UIImage(named: "ic_mode_edit_white"), type: .Default) { (sheet) in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Edit graffiti")
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("edit_graffiti", label: nil)
                
                self.edit()
            }
            actionSheet.addButtonWithTitle(streamable?.isPrivate == true ? NSLocalizedString("controller_streamable_options_public", comment: "") : NSLocalizedString("controller_streamable_options_private", comment: ""), image: UIImage(named: streamable?.isPrivate == true ? "ic_visibility_white" : "ic_visibility_off_white"), type: .Default) { (sheet) in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Toggle privacy")
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("toggle_graffiti_privacy", label: nil)
                
                self.togglePrivacy()
            }
            actionSheet.addButtonWithTitle(NSLocalizedString("controller_create_share_save", comment: ""), image: UIImage(named: "ic_file_download_white"), type: .Default) { (sheet) in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Save graffiti")
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("save", label: nil)
                
                self.save()
            }
//            actionSheet.addButtonWithTitle(NSLocalizedString("controller_streamable_options_set_avatar", comment: ""), image: UIImage(named: "ic_person_white"), type: .Default) { (sheet) in
//                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Set as profile picture")
//                
//                // Register analytics events.
//                AnalyticsUtils.sendAppEvent("set_as_profile_picture", label: nil)
//                
//                self.setAsAvatar()
//            }
        }
        actionSheet.addButtonWithTitle(NSLocalizedString("controller_streamable_options_flag", comment: ""), image: UIImage(named: "ic_flag_white"), type: .Default) { (sheet) in
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Flag graffiti")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("flag_inappropriate", label: nil)
            
            self.flag()
        }
        actionSheet.addButtonWithTitle(NSLocalizedString("controller_streamable_options_explore", comment: ""), image: UIImage(named: "ic_near_me_white"), type: .Default) { (sheet) in
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Explore area")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("explore_map_area", label: nil)
            
            self.exploreArea()
        }
//        actionSheet.addButtonWithTitle(NSLocalizedString("controller_streamable_options_copy_link", comment: ""), image: UIImage(named: "ic_link_white"), type: .Default) { (sheet) in
//            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Copy link")
//            
//            // Register analytics events.
//            AnalyticsUtils.sendAppEvent("copy_link", label: nil)
//            
//            self.copyLink()
//        }
        if isMe() {
            actionSheet.addButtonWithTitle(NSLocalizedString("other_delete", comment: ""), image: UIImage(named: "ic_clear_white"), type: .Destructive) { (sheet) in
                DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Delete graffiti")
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("delete_graffiti", label: nil)
                
                self.delete()
            }
        }
        showActionSheet(actionSheet)
    }
    
    @IBAction func onClickShare(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Share graffiti")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("share", label: nil)
        
        Utils.shareImage(streamableImage.imageView!.image, viewController: self, fromView: shareContainer)
    }
    
    @IBAction func onClickLike(sender: AnyObject) {
        if streamable!.likedByCurrentUser! { // Unlike.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Unlike graffiti")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("unlike", label: nil)
            
            streamable!.likersCount! -= 1
            
            GTStreamableManager.unlike(streamable!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Like.
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Like graffiti")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("like", label: nil)
            
            streamable!.likersCount! += 1
            
            GTStreamableManager.like(streamable!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        
        streamable?.likedByCurrentUser = !streamable!.likedByCurrentUser!
        
        loadData()
    }
    
    @IBAction func onClickComment(sender: AnyObject) {
        ViewControllerUtils.showComments(streamable!, viewController: self)
    }
    
    func isMe() -> Bool {
        return self.streamable!.user!.id == GTMeManager.sharedInstance.loggedInUser!.id
    }
    
    // MARK: - Events
    
    func registerForEvents() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.genericEventHandler(_:)), name: GTEvents.CommentPosted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.genericEventHandler(_:)), name: GTEvents.CommentDeleted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.ownerChangeEventHandler(_:)), name: GTEvents.UserAvatarChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.ownerChangeEventHandler(_:)), name: GTEvents.UserProfileChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleStreamableEventHandler(_:)), name: GTEvents.StreamableChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.singleStreamableEventHandler(_:)), name: GTEvents.StreamableLikesChanged, object: nil)
    }
    
    func ownerChangeEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let user = notification.userInfo!["user"] as! GTUser
        if streamable!.user!.isEqual(user) {
            streamable!.user!.softCopy(user)
            
            self.loadData()
            self.loadAvatar()
        }
    }
    
    func singleStreamableEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        let s = notification.userInfo!["streamable"] as! GTStreamable
        if streamable!.isEqual(s) {
            streamable!.softCopy(s)
            
            self.loadData()
            self.loadStreamableImage()
        }
    }
    
    func genericEventHandler(notification: NSNotification) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Received app event - \(notification)")
        
        loadData()
    }
    
    // MARK: - Actions
    
    func flag() {
        DialogBuilder.showYesNoAlert(self, status: NSLocalizedString("controller_streamable_options_flag_prompt", comment: ""), title: App.Title, yesAction: {
                GTStreamableManager.flag(self.streamable!.id!, successBlock: { (response) in
            }, failureBlock: { (response) in
                    
            })
        }) { 
            
        }
    }
    
    func exploreArea() {
        ViewControllerUtils.showExplorer(streamable?.latitude, longitude: streamable?.longitude, viewController: self)
    }
    
    func save() {
        self.view.showActivityView()
        self.view.rn_activityView.dimBackground = false
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            UIImageWriteToSavedPhotosAlbum(self.streamableImage!.imageView!.image!, nil, nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3, block: {
                    DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_streamable_options_save_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
                })
            })
        })
    }
    
    func copyLink() {
        UIPasteboard.generalPasteboard().string = streamable!.asset!.link
    }
    
    func delete() {
        DialogBuilder.showYesNoAlert(self, status: NSLocalizedString("controller_streamable_options_delete_prompt", comment: ""), title: App.Title, yesAction: {
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.deleteStreamable(self.streamable!.id!, successBlock: { (response) in
                Utils.runWithDelay(0.3, block: {
                    (self.transitioningDelegate as! ImageCellTransitioningDelegate).resetState()
                    self.transitioningDelegate = nil
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }, failureBlock: { (response) in
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }) {
            
        }
    }
    
    func edit() {
        let parent = self.presentingViewController
        
        (self.transitioningDelegate as! ImageCellTransitioningDelegate).resetState()
        self.transitioningDelegate = nil
        self.dismissViewControllerAnimated(true, completion: {
            let vc = UIStoryboard(name: "CreateStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CreateViewController") as! CreateViewController
            vc.toEdit = self.streamable
            vc.toEditImage = self.streamableImage.imageView.image
            
            parent!.presentViewController(vc, animated: true, completion: nil)
        })
    }
    
    func togglePrivacy() {
        if streamable!.isPrivate! { // Make public.
            GTMeManager.markStreamablePublic(streamable!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Make private.
            GTMeManager.markStreamablePrivate(streamable!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        
        streamable?.isPrivate = !streamable!.isPrivate!
    }
    
    func setAsAvatar() {
        let image = self.streamableImage.imageView.image
        if image != nil {
            startCropperForImage(image!)
        }
    }
    
    // MARK: - Images
    
    override func didChooseImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            if self.streamable!.user!.isEqual(GTMeManager.sharedInstance.loggedInUser) { // Reload avatar in case the streamable creator is changing their avatar.
                self.streamable!.user!.softCopy(GTMeManager.sharedInstance.loggedInUser!)
                
                self.loadAvatar()
            }
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_avatar_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }
        
        if image != nil { // Saving a new image.
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.editAvatar(image!, successBlock: { (response) in
                avatarSuccessBlock()
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
    }
    
    override func cropAspectRatio() -> CGSize {
        let width = CGFloat(300);
        let height = width;
        
        return CGSizeMake(width, width / (width / height))
    }
    
    // MARK: - Loading
    
    func loadData() {
        // Setup labels.
        self.nameField.text = streamable?.user!.getFullName()
        self.usernameField.text = streamable?.user!.getMentionUsername()
        
        self.likesLbl.text = "\(streamable!.likersCount!)"
        self.commentsLbl.text = "\(streamable!.commentsCount!)"
        
        self.likesContainer.backgroundColor = streamable!.likedByCurrentUser! ? AppConfig.sharedInstance.theme!.primaryColor : UIColor.blackColor().colorWithAlphaComponent(0.2)
    }
    
    func loadAvatar() {
        self.avatar.asset = streamable!.user!.avatar
    }
    
    func loadStreamableImage() {
        let streamableImageView = streamableImage.imageView as! StreamableImageView
        streamableImageView.asset = streamable?.asset
    }
    
    // MARK: - ZoomableImageViewDelegate
    
    func didZoomImageView(imageView: ZoomableImageView) {
        hideViews()
    }
    
    func didTapImageView(imageView: ZoomableImageView) {
        viewsVisible = !viewsVisible
        
        if viewsVisible {
            showViews()
        }
        else {
            hideViews()
        }
    }
    
    func hideViews() {
        viewsVisible = false
        
        Utils.hideView(topMenu)
        Utils.hideView(bottomMenu)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    func showViews() {
        viewsVisible = true
        
        Utils.showView(topMenu)
        Utils.showView(bottomMenu)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    // MARK: - Orientation
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) in
            self.streamableImage.scrollView.zoomScale = self.streamableImage.minZoomScale
        }, completion: nil)
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        streamableImage.delegate = self
        
        let streamableImageView = StreamableImageView(frame: CGRectZero)
        streamableImageView.shouldLoadFullAsset = true
        streamableImage.replaceImageView(streamableImageView)
    }
    
    func setupContainers() {
        likesContainer.layer.cornerRadius = 3
        commentsContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
        menuContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
        shareContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
        
        viewsVisible = false
        topMenu.alpha = 0
        bottomMenu.alpha = 0
    }
}
