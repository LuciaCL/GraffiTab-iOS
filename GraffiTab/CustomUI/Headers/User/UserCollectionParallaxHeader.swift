//
//  UserCollectionParallaxHeader.swift
//  GraffiTab
//
//  Created by Georgi Christov on 16/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import iCarousel

class UserCollectionParallaxHeader: UICollectionReusableView, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    
    var item: GTUser?
    
    class func reusableIdentifier() -> String {
        return "UserCollectionParallaxHeader"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupContainerViews()
        setupImageViews()
        setupCarousel()
        setupPageControl()
    }
    
    func setItem(item: GTUser?) {
        self.item = item
        
        loadAvatar()
        loadCover()
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        avatar.image = nil
        
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item!.avatar!.link! { // Verify we're still loading the current image.
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
    
    func loadCover() {
        if item?.cover != nil {
            Alamofire.request(.GET, item!.cover!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item!.cover!.link! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.cover,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                self.cover.image = image
                            },
                            completion: nil)
                    }
            }
        }
    }
    
    // MARK: - iCarouselDelegate
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return 2
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        if index == 0 {
            let view = UIView()
            view.backgroundColor = .clearColor()
            view.frame = carousel.bounds
            return view
        }
        
        let aboutView: UserAboutView
        if view == nil {
            aboutView = NSBundle.mainBundle().loadNibNamed("UserAboutView", owner: self, options: nil).first as! UserAboutView
            aboutView.frame = carousel.bounds;
        }
        else {
            aboutView = view as! UserAboutView
            aboutView.frame = carousel.bounds;
        }
        
        return aboutView
    }
    
    func carouselDidScroll(carousel: iCarousel) {
        var alpha = max(0, carousel.scrollOffset - 0.3)
        alpha = min(0.7, alpha)
        carousel.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    // MARK: - Setup
    
    func setupContainerViews() {
        Utils.applyShadowEffectToView(self)
    }
    
    func setupImageViews() {
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 3
    }
    
    func setupCarousel() {
        carousel.type = .Linear;
        carousel.bounceDistance = 0.2;
        carousel.decelerationRate = 0.8;
    }
    
    func setupPageControl() {
        pageControl.numberOfPages = numberOfItemsInCarousel(carousel)
    }
}
