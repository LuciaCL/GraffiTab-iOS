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

protocol UserHeaderDelegate {
    
    func didTapCover(user: GTUser)
    func didTapAvatar(user: GTUser)
    func didTapAbout(user: GTUser)
    
    func didTapStreamables(user: GTUser)
    func didTapFollowers(user: GTUser)
    func didTapFollowing(user: GTUser)
    
    func didTapList(user: GTUser)
    func didTapGrid(user: GTUser)
    func didTapFavourites(user: GTUser)
    func didTapMap(user: GTUser)
}

class UserCollectionParallaxHeader: UICollectionReusableView, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var streamablesCountLbl: UILabel!
    @IBOutlet weak var streamablesLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followingCountLbl: UILabel!
    @IBOutlet weak var followingLbl: UILabel!
    
    var delegate: UserHeaderDelegate?
    var item: GTUser? {
        didSet {
            setItem()
        }
    }
    
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
        setupGestureRecognizers()
    }
    
    func setItem() {
        // Setup labels.
        self.nameField.text = item!.getFullName()
        self.usernameField.text = item!.getMentionUsername()
        
        setStatsAndAdditionalInfo()
        
        loadAvatar()
        loadCover()
    }
    
    func setStatsAndAdditionalInfo() {
        if item?.streamablesCount != nil {
            self.streamablesCountLbl.text = item?.streamablesCountAsString()
            self.followersCountLbl.text = item?.followersCountAsString()
            self.followingCountLbl.text = item?.followingCountAsString()
        }
        else {
            self.streamablesCountLbl.text = "--"
            self.followersCountLbl.text = "--"
            self.followingCountLbl.text = "--"
        }
        
        carousel.reloadData()
        
        setupPageControl()
    }
    
    @IBAction func onClickAbout(sender: AnyObject?) {
        if delegate != nil {
            delegate?.didTapAbout(item!)
        }
    }
    
    @IBAction func onClickAvatar(sender: AnyObject?) {
        if delegate != nil {
            delegate?.didTapAvatar(item!)
        }
    }
    
    @IBAction func onClickCover(sender: AnyObject?) {
        if delegate != nil {
            delegate?.didTapCover(item!)
        }
    }
    
    @IBAction func onClickList(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapList(item!)
        }
    }
    
    @IBAction func onClickGrid(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapGrid(item!)
        }
    }
    
    @IBAction func onClickFavourites(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapFavourites(item!)
        }
    }
    
    @IBAction func onClickMap(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapMap(item!)
        }
    }
    
    @IBAction func onClickGraffiti(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapStreamables(item!)
        }
    }
    
    @IBAction func onClickFollowers(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapFollowers(item!)
        }
    }
    
    @IBAction func onClickFollowing(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapFollowing(item!)
        }
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        if item?.avatar != nil {
            Alamofire.request(.GET, item!.avatar!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.avatar == nil {
                        return
                    }
                    
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
                    
                    if self.item!.cover == nil {
                        return
                    }
                    
                    if response.request?.URLString == self.item!.cover!.link! { // Verify we're still loading the current image.
                        UIView.transitionWithView(self.cover,
                            duration: App.ImageAnimationDuration,
                            options: UIViewAnimationOptions.TransitionCrossDissolve,
                            animations: {
                                if image != nil {
                                    self.cover.image = image
                                }
                                else {
                                    self.cover.image = UIImage(named: "grafitab_login")
                                }
                            },
                            completion: nil)
                    }
            }
        }
    }
    
    // MARK: - iCarouselDelegate
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        let pagerVisible = (item?.about != nil || item?.website != nil)
        return pagerVisible ? 2 : 1
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
        
        aboutView.item = item
        
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
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return carousel.frame.width
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        if index == 0 {
            onClickCover(nil)
        }
        else if index == 1 {
            onClickAbout(nil)
        }
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
        pageControl.hidesForSinglePage = true
    }
    
    func setupGestureRecognizers() {
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAvatar)))
        
        streamablesCountLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickGraffiti)))
        streamablesLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickGraffiti)))
        followersCountLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickFollowers)))
        followersLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickFollowers)))
        followingCountLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickFollowing)))
        followingLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickFollowing)))
    }
}
