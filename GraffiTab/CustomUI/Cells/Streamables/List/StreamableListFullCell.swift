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
        
        setupImageViews()
        setupGestureRecognizers()
        setupLabels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        Utils.applyShadowEffectToCellView(containerView)
    }
    
    override func setItem() {
        super.setItem()
        
        // Setup labels.
        self.dateField.text = DateUtils.timePassedSinceDate((item?.createdOn)!);
        
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        setStats()
    }
    
    func setStats() {
        self.likesLbl.text = String(format: "%i %@", item!.likersCount!, item!.likersCount! == 1 ? NSLocalizedString("cell_streamable_like", comment: "") : NSLocalizedString("cell_streamable_likes", comment: ""));
        self.commentsLbl.text = String(format: "%i %@", item!.commentsCount!, item!.commentsCount! == 1 ? NSLocalizedString("cell_streamable_comment", comment: "") : NSLocalizedString("cell_streamable_comments", comment: ""));
        
        self.likeBtn.setTitle(DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS ? "" : (item!.likedByCurrentUser! ? NSLocalizedString("cell_streamable_liked", comment: "") : NSLocalizedString("cell_streamable_like", comment: "")), forState: .Normal)
        self.likeBtn.tintColor = item!.likedByCurrentUser! ? UIColor(hexString: Colors.Green) : UIColor(hexString: Colors.Main)
        self.likeBtn.setTitleColor(self.likeBtn.tintColor, forState: .Normal)
    }
    
    override func getStreamableImageUrl() -> String {
        return item!.asset!.link!
    }
    
    override func onClickLike(sender: AnyObject) {
        if item!.likedByCurrentUser! { // Unlike.
            item!.likersCount! -= 1
            
            GTStreamableManager.unlike(item!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                
            })
        }
        else { // Like.
            item!.likersCount! += 1
            
            GTStreamableManager.like(item!.id!, successBlock: { (response) in
                
            }, failureBlock: { (response) in
                    
            })
        }
        
        item?.likedByCurrentUser = !item!.likedByCurrentUser!
        
        setStats()
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        thumbnail.shouldLoadFullAsset = true
    }
    
    override func setupGestureRecognizers() {
        super.setupGestureRecognizers()
        
        likesLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickLikers)))
        commentsLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickComments)))
        
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
        usernameField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
        nameField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickUser)))
    }
    
    func setupLabels() {
        commentBtn.setTitle(DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS ? "" : NSLocalizedString("cell_streamable_comment", comment: ""), forState: .Normal)
        shareBtn.setTitle(DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS ? "" : NSLocalizedString("controller_create_share", comment: ""), forState: .Normal)
    }
}
