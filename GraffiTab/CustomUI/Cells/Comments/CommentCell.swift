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
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var errorView: UIImageView!
    
    var delegate: MessageDelegate?
    var item: GTComment? {
        didSet {
            setItem()
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
        
        self.avatar.user = item!.user
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
