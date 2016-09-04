//
//  StreamableTrendingCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class StreamableTrendingCell: StreamableCell {

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likesImg: TintImageView!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var commentsImg: TintImageView!
    
    override class func reusableIdentifier() -> String {
        return "StreamableTrendingCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupImageViews()
        setupGestureRecognizers()
        setupButtons()
        setupLabels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Utils.applyShadowEffect(self, offset: CGSizeMake(1, 1), opacity: 0.1, radius: 2.0)
    }
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        self.likesLbl.text = String(format: "%i", item!.likersCount!);
        self.commentsLbl.text = String(format: "%i", item!.commentsCount!);
        
        self.likesImg.tintColor = item!.likedByCurrentUser! ? AppConfig.sharedInstance.theme!.primaryColor : UIColor.lightGrayColor()
        self.likesLbl.textColor = self.likesImg.tintColor
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        thumbnail.shouldLoadFullAsset = true
    }
    
    override func setupGestureRecognizers() {
        super.setupGestureRecognizers()
        
        likesLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickLikers)))
        likesImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickLikers)))
        commentsLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickComments)))
        commentsImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickComments)))
        
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
        usernameField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
        nameField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
    }
    
    func setupButtons() {
        self.likesImg.tintColor = AppConfig.sharedInstance.theme?.metadataColor
        self.commentsImg.tintColor = AppConfig.sharedInstance.theme?.metadataColor
    }
    
    func setupLabels() {
        self.likesLbl.textColor = AppConfig.sharedInstance.theme?.metadataColor
        self.commentsLbl.textColor = AppConfig.sharedInstance.theme?.metadataColor
    }
}
