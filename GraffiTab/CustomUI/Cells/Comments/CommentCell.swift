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

protocol MessageDelegate: class {
    
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
    
    weak var delegate: MessageDelegate?
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
            let text = String(format: "%@ (%@)", item!.text!, NSLocalizedString("cell_comment_edited", comment: ""))
            let attString = NSMutableAttributedString(string: text)
            let range = (text as NSString).rangeOfString(String(format: "(%@)", NSLocalizedString("cell_comment_edited", comment: "")))
            attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(textLbl.font.pointSize - 4), range: range)
            self.textLbl.attributedText = attString
        }
        else {
            textLbl.text = item!.text
        }
        
        dateLbl.text = DateUtils.notificationTimePassedSinceDate((item?.createdOn)!);
        
        // Setup error view.
        if item?.status == .Failed {
            textLbl.textColor = UIColor(hexString: "#d0d0d0")
            dateLbl.textColor = textLbl.textColor
            errorView.hidden = false
            textLblTrailingConstraint.constant = 2 * 8 + errorView.frame.width
        }
        else {
            if item!.status == .Sending {
                textLbl.textColor = UIColor(hexString: "#d0d0d0")
            }
            else {
                textLbl.textColor = UIColor.darkGrayColor()
                
                if item!.updatedOn != nil {
                    let attString = NSMutableAttributedString(attributedString: textLbl.attributedText!)
                    let range = (textLbl.text! as NSString).rangeOfString(String(format: "(%@)", NSLocalizedString("cell_comment_edited", comment: "")))
                    attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#d0d0d0")!, range: range)
                    self.textLbl.attributedText = attString
                }
            }
            
            dateLbl.textColor = item?.status == .Sending ? textLbl.textColor : UIColor.lightGrayColor()
            errorView.hidden = true
            textLblTrailingConstraint.constant = 8
        }
        
        self.avatar.asset = item!.user!.avatar
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
        textLbl.hashtagColor = AppConfig.sharedInstance.theme!.hashtagColor!
        textLbl.mentionColor = AppConfig.sharedInstance.theme!.mentionColor!
        textLbl.URLColor = AppConfig.sharedInstance.theme!.linksColor!
        
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
