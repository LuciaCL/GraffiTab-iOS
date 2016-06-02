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
        setupContainerViews()
        setupGestureRecognizers()
    }
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        self.likesLbl.text = String(format: "%i", item!.likersCount!);
        self.commentsLbl.text = String(format: "%i", item!.commentsCount!);
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        thumbnail.shouldLoadFullAsset = true
    }
    
    func setupContainerViews() {
        Utils.applyShadowEffectToView(self)
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
}
