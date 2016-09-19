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

protocol UserHeaderDelegate: class {
    
    func didTapCover(user: GTUser)
    func didTapAvatar(user: GTUser)
    func didTapAbout(user: GTUser)
    
    func didTapStreamables(user: GTUser)
    func didTapFollowers(user: GTUser)
    func didTapFollowing(user: GTUser)
    
    func didTapList(user: GTUser)
    func didTapGrid(user: GTUser)
    func didTapFavourites(user: GTUser)
    func didTapTags(user: GTUser)
}

class UserCollectionParallaxHeader: UICollectionReusableView, iCarouselDelegate, iCarouselDataSource {

    @IBOutlet weak var cover: CoverImageView!
    @IBOutlet weak var avatar: AvatarImageView!
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
    @IBOutlet weak var listBtn: TintButton!
    @IBOutlet weak var gridBtn: TintButton!
    @IBOutlet weak var likesBtn: TintButton!
    @IBOutlet weak var tagsBtn: TintButton!
    
    weak var delegate: UserHeaderDelegate?
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
        
        setupImageViews()
        setupCarousel()
        setupPageControl()
        setupGestureRecognizers()
        setupLabels()
        setupButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Utils.applyShadowEffect(self, offset: CGSizeMake(1, 1), opacity: 0.1, radius: 2.0)
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
    
    @IBAction func onClickTags(sender: AnyObject) {
        if delegate != nil {
            delegate?.didTapTags(item!)
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
        self.avatar.asset = item!.avatar
    }
    
    func loadCover() {
        self.cover.asset = item!.cover
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
    
    func setupImageViews() {
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 3
        avatar.shouldLoadFullAsset = true
        cover.shouldLoadFullAsset = true
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
    
    func setupLabels() {
        streamablesLbl.text = NSLocalizedString("view_profile_header_graffiti", comment: "")
        followersLbl.text = NSLocalizedString("view_profile_header_followers", comment: "")
        followingLbl.text = NSLocalizedString("view_profile_header_following", comment: "")
        
        nameField.font = nameField.font.fontWithSize(DeviceType.IS_IPAD ? 24 : 17)
        usernameField.font = usernameField.font.fontWithSize(DeviceType.IS_IPAD ? 16 : 13)
    }
    
    func setupButtons() {
        listBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        gridBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        likesBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
        tagsBtn.tintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
}
