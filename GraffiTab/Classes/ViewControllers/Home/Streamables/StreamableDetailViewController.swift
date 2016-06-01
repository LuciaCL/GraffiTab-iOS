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
import CNPGridMenu

let menuFlagTitle = "Flag"
let menuExploreTitle = "Explore Area"
let menuSaveTitle = "Save"
let menuCopyLinkTitle = "Copy Link"
let menuDeleteTitle = "Delete"
let menuEditTitle = "Edit"
let menuMakePrivateTitle = "Make Private"
let menuMakePublicTitle = "Make Public"

class StreamableDetailViewController: BackButtonViewController, ZoomableImageViewDelegate, CNPGridMenuDelegate {

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
    var thumbnailImage: UIImage?
    var viewsVisible = true
    var fullyLoadedThumbnail = false
    
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
        
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickUser(sender: AnyObject) {
        ViewControllerUtils.showUserProfile(streamable!.user!, viewController: self)
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickMenu(sender: AnyObject) {
        var items = [CNPGridMenuItem]()
        
        let flag = CNPGridMenuItem()
        flag.title = menuFlagTitle
        flag.icon = UIImage(named: "ic_notifications")
        items.append(flag)
        
        let explore = CNPGridMenuItem()
        explore.title = menuExploreTitle
        explore.icon = UIImage(named: "ic_near_me_white")
        items.append(explore)
        
        let download = CNPGridMenuItem()
        download.title = menuSaveTitle
        download.icon = UIImage(named: "download")
        items.append(download)
        
        let copyLink = CNPGridMenuItem()
        copyLink.title = menuCopyLinkTitle
        copyLink.icon = UIImage(named: "copy_link")
        items.append(copyLink)
        
        if isMe() {
            let delete = CNPGridMenuItem()
            delete.title = menuDeleteTitle
            delete.icon = UIImage(named: "trash")
            items.append(delete)
            
            let edit = CNPGridMenuItem()
            edit.title = menuEditTitle
            edit.icon = UIImage(named: "edit")
            items.append(edit)
            
            if streamable!.isPrivate! {
                let privary = CNPGridMenuItem()
                privary.title = menuMakePublicTitle
                privary.icon = UIImage(named: "unlock")
                items.append(privary)
            }
            else {
                let privary = CNPGridMenuItem()
                privary.title = menuMakePrivateTitle
                privary.icon = UIImage(named: "lock")
                items.append(privary)
            }
        }
        
        let menu = CNPGridMenu(menuItems: items)
        menu.delegate = self
        self.presentGridMenu(menu, animated: true, completion: nil)
    }
    
    @IBAction func onClickShare(sender: AnyObject) {
        Utils.shareImage(streamableImage.imageView!.image!, viewController: self)
    }
    
    @IBAction func onClickLike(sender: AnyObject) {
        if streamable!.likedByCurrentUser! { // Unlike.
            streamable!.likersCount! -= 1
            
            GTStreamableManager.unlike(streamable!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        else { // Like.
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
        return self.streamable!.user!.id == GTSettings.sharedInstance.user!.id
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
        print("DEBUG: Received app event - \(notification)")
        let user = notification.userInfo!["user"] as! GTUser
        if streamable!.user!.isEqual(user) {
            streamable!.user!.softCopy(user)
            
            self.loadData()
            self.loadAvatar()
        }
    }
    
    func singleStreamableEventHandler(notification: NSNotification) {
        print("DEBUG: Received app event - \(notification)")
        let s = notification.userInfo!["streamable"] as! GTStreamable
        if streamable!.isEqual(s) {
            streamable!.softCopy(s)
            
            self.fullyLoadedThumbnail = false
            
            self.loadData()
            self.loadStreamableImage()
        }
    }
    
    func genericEventHandler(notification: NSNotification) {
        print("DEBUG: Received app event - \(notification)")
        loadData()
    }
    
    // MARK: - Actions
    
    func flag() {
        DialogBuilder.showYesNoAlert("Mark this graffiti as inappropriate?", title: App.Title, yesAction: { 
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
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            UIImageWriteToSavedPhotosAlbum(self.streamableImage!.imageView!.image!, nil, nil, nil);
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3, block: {
                    DialogBuilder.showSuccessAlert("This graffiti was saved in your photos album", title: App.Title)
                })
            })
        })
    }
    
    func copyLink() {
        UIPasteboard.generalPasteboard().string = streamable!.asset!.link
    }
    
    func delete() {
        DialogBuilder.showYesNoAlert("Are you sure you want to delete this graffiti?", title: App.Title, yesAction: {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.deleteStreamable(self.streamable!.id!, successBlock: { (response) in
                Utils.runWithDelay(0.3, block: {
                    self.transitioningDelegate = nil
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }, failureBlock: { (response) in
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
            })
        }) {
            
        }
    }
    
    func edit() {
        let parent = self.presentingViewController
        
        self.transitioningDelegate = nil
        self.dismissViewControllerAnimated(true, completion: {
            ViewControllerUtils.checkCameraAndPhotosPermissions {
                let vc = UIStoryboard(name: "CreateStoryboard", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CreateViewController") as! CreateViewController
                vc.toEdit = self.streamable
                vc.toEditImage = self.streamableImage.imageView.image
                
                parent!.presentViewController(vc, animated: true, completion: nil)
            }
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
    
    // MARK: - Loading
    
    func loadData() {
        // Setup labels.
        self.nameField.text = streamable?.user!.getFullName()
        self.usernameField.text = streamable?.user!.getMentionUsername()
        
        self.likesLbl.text = "\(streamable!.likersCount!)"
        self.commentsLbl.text = "\(streamable!.commentsCount!)"
        
        self.likesContainer.backgroundColor = streamable!.likedByCurrentUser! ? UIColor(hexString: Colors.Green) : UIColor.blackColor().colorWithAlphaComponent(0.2)
    }
    
    func loadAvatar() {
        self.avatar.asset = streamable!.user!.avatar
    }
    
    func loadStreamableImage() {
        streamableImage.imageView.image = thumbnailImage
        
        if !fullyLoadedThumbnail {
            Alamofire.request(.GET, streamable!.asset!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.streamable!.asset!.link! { // Verify we're still loading the current image.
                        self.fullyLoadedThumbnail = true
                        
                        self.streamableImage.imageView.image = image
                    }
            }
        }
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
    
    // MARK: - CNPGridMenuDelegate
    
    func gridMenuDidTapOnBackground(menu: CNPGridMenu!) {
        self.dismissGridMenuAnimated(true, completion: nil)
    }
    
    func gridMenu(menu: CNPGridMenu!, didTapOnItem item: CNPGridMenuItem!) {
        self.dismissGridMenuAnimated(true) { 
            if item.title == menuFlagTitle {
                self.flag()
            }
            else if item.title == menuExploreTitle {
                self.exploreArea()
            }
            else if item.title == menuSaveTitle {
                self.save()
            }
            else if item.title == menuCopyLinkTitle {
                self.copyLink()
            }
            else if item.title == menuDeleteTitle {
                self.delete()
            }
            else if item.title == menuEditTitle {
                self.edit()
            }
            else if item.title == menuMakePrivateTitle || item.title == menuMakePublicTitle {
                self.togglePrivacy()
            }
        }
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
    }
    
    func setupContainers() {
        likesContainer.layer.cornerRadius = 3
        commentsContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
        menuContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
        shareContainer.layer.cornerRadius = likesContainer.layer.cornerRadius
    }
}
