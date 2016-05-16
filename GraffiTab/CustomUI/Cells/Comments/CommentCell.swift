//
//  CommentCell.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/05/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import Alamofire
import ActiveLabel

protocol MessageDelegate {
    
    func didTapAvatar(user: GTUser)
    
    func didTapErrorView(comment: GTComment)
    
    func didTapHashtag(hashtag: String)
    func didTapUsername(username: String)
    func didTapLink(link: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var textLbl: ActiveLabel!
    @IBOutlet weak var textLblTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var errorView: UIImageView!
    
    var delegate: MessageDelegate?
    var previousItem: GTComment?
    var previousItemRequest: Request?
    var item: GTComment? {
        didSet {
            setItem()
            
            previousItem = item
        }
    }
    
    class func reusableIdentifier() -> String {
        return "CommentCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
        setupGestureRecognizers()
    }
    
    func setItem() {
        // Setup labels.
        let name = String(format: "%@ %@", item!.user!.getFullName(), item!.user!.getMentionUsername())
        let attString = NSMutableAttributedString(string: name)
        let range = (name as NSString).rangeOfString(item!.user!.getMentionUsername())
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(nameLbl.font.pointSize - 2), range: range)
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
        self.nameLbl.attributedText = attString
        
        if item?.updatedOn != nil {
            let text = String(format: "%@ (edited)", item!.text!)
            let attString = NSMutableAttributedString(string: text)
            let range = (text as NSString).rangeOfString("(edited)")
            attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(textLbl.font.pointSize - 4), range: range)
            attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: range)
            self.textLbl.attributedText = attString
        }
        else {
            textLbl.text = item!.text
        }
        
        dateLbl.text = DateUtils.notificationTimePassedSinceDate((item?.createdOn)!);
        
        // Setup error view.
        if item?.status == .Failed {
            errorView.hidden = false
            textLblTrailingConstraint.constant = 2 * 8 + errorView.frame.width
        }
        else {
            errorView.hidden = true
            textLblTrailingConstraint.constant = 8
        }
        
        loadAvatar()
    }
    
    func onClickErrorView() {
        if delegate != nil {
            delegate?.didTapErrorView(item!)
        }
    }
    
    func onClickAvatar() {
        if delegate != nil {
            delegate?.didTapAvatar(item!.user!)
        }
    }
    
    // MARK: - Loading
    
    func loadAvatar() {
        if item?.user?.avatar == nil {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        else if previousItem != nil && previousItem!.user?.id != item?.user?.id {
            avatar.image = nil
            previousItemRequest?.cancel()
        }
        
        if item!.user!.avatar != nil {
            previousItemRequest = Alamofire.request(.GET, item!.user!.avatar!.thumbnail!)
                .responseImage { response in
                    let image = response.result.value
                    
                    if self.item!.user!.avatar == nil {
                        self.avatar.image = nil
                    }
                    else if response.request?.URLString == self.item?.user!.avatar?.thumbnail! { // Verify we're still loading the current image.
                        self.avatar.image = image
                    }
            }
        }
    }
    
    // MARK: - Setup
    
    func setupLabels() {
        textLbl.hashtagColor = UIColor(hexString: Colors.Awesome)!
        textLbl.mentionColor = UIColor(hexString: Colors.Awesome)!
        textLbl.URLColor = UIColor(hexString: Colors.Links)!
        
        textLbl.handleURLTap { (url) in
            if self.delegate != nil {
                self.delegate?.didTapLink(url.absoluteString)
            }
        }
        textLbl.handleHashtagTap { (hashtag) in
            if self.delegate != nil {
                self.delegate?.didTapHashtag(hashtag)
            }
        }
        textLbl.handleMentionTap { (mention) in
            if self.delegate != nil {
                self.delegate?.didTapUsername(mention)
            }
        }
    }
    
    func setupGestureRecognizers() {
        errorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickErrorView)))
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAvatar)))
        nameLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickAvatar)))
    }
}
