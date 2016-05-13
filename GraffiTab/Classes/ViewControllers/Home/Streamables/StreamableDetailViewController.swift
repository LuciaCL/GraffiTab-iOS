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
    
    var streamable: GTStreamable?
    var thumbnailImage: UIImage?
    var viewsVisible = true
    var fullyLoadedThumbnail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImageViews()
        
        loadStreamableImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Loading
    
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
}
