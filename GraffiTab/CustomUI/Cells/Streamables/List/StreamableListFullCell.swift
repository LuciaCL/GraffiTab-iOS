//
//  StreamableListFullCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire

class StreamableListFullCell: StreamableCell {

    @IBOutlet weak var avatar: UIImageView!
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
    }
    
    override func setItem(item: GTStreamable?) {
        super.setItem(item)
        
        // Setup labels.
        self.dateField.text = DateUtils.timePassedSinceDate((item?.createdOn)!);
        
        self.nameField.text = item!.user?.getFullName();
        self.usernameField.text = item!.user?.getMentionUsername();
        
        let likesCount = 0
        let commentsCount = 0
        self.likesLbl.text = String(format: "%i %@", likesCount, likesCount == 1 ? "Like" : "Likes");
        self.commentsLbl.text = String(format: "%i %@", commentsCount, commentsCount == 1 ? "Comment" : "Comments");
        
        loadAvatar()
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        if item?.user?.avatar != nil {
            Alamofire.request(.GET, (item?.user!.avatar?.link)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item?.user!.avatar?.link! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
        else {
            avatar.image = nil
        }
    }
    
    override func loadImage() {
        if item?.asset != nil {
            Alamofire.request(.GET, (item?.asset?.link)!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if response.request?.URLString == self.item?.asset?.link { // Verify we're still loading the current image.
                        self.thumbnail.image = image
                    }
            }
        }
        else {
            thumbnail.image = nil
        }
    }
    
    // MARK: - Setup
    
    func setupImageViews() {
        Utils.applyShadowEffectToView(containerView)
        
        avatar.layer.cornerRadius = 5
    }
}
