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

class StreamableDetailViewController: BackButtonViewController, ZoomableImageViewDelegate {

    @IBOutlet weak var streamableImage: ZoomableImageView!
    @IBOutlet weak var topMenu: UIView!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var avatar: UIImageView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImageViews()
        setupContainers()
        
        loadData()
        loadAvatar()
        loadStreamableImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickMenu(sender: AnyObject) {
        // TODO:
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
        // TODO:
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
        avatar.image = nil
        
        if streamable?.user?.avatar != nil {
            Alamofire.request(.GET, streamable!.user!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.streamable?.user!.avatar!.thumbnail! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.avatar,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.avatar.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
    
    func loadStreamableImage() {
        streamableImage.imageView.image = thumbnailImage
        
        if !fullyLoadedThumbnail {
            Alamofire.request(.GET, streamable!.asset!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.streamable!.asset!.link! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.streamableImage.imageView,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.streamableImage.imageView.image = image
                            },
                            completion: nil)
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
