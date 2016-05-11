//
//  StreamableListFullCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class StreamableListFullCell: StreamableCell {

    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var likeBtn: TintButton!
    @IBOutlet weak var commentBtn: TintButton!
    @IBOutlet weak var shareBtn: TintButton!
    @IBOutlet weak var containerView: UIView!
    
    override class func reusableIdentifier() -> String {
        return "StreamableListFullCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupContainerViews()
        setupGestureRecognizers()
    }
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.dateField.text = DateUtils.timePassedSinceDate((item?.createdOn)!);
        
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        self.likesLbl.text = String(format: "%i %@", item!.likersCount!, item!.likersCount! == 1 ? "Like" : "Likes");
        self.commentsLbl.text = String(format: "%i %@", item!.commentsCount!, item!.commentsCount! == 1 ? "Comment" : "Comments");
    }
    
    override func getStreamableImageUrl() -> String {
        return item!.asset!.link!
    }
    
    // MARK: - Setup
    
    func setupContainerViews() {
        Utils.applyShadowEffectToView(containerView)
    }
    
    func setupGestureRecognizers() {
        likesLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickLikers)))
        commentsLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickComments)))
    }
}
