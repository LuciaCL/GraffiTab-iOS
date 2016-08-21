//
//  ProfileFollowButton.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class ProfileFollowButton: UIView {

    @IBOutlet weak var followBtnTitle: UILabel!
    @IBOutlet weak var followBtnImage: TintImageView!
    @IBOutlet weak var followBtnWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicInit()
    }
    
    func basicInit() {
        self.applyMaterializeStyle()
    }
    
    // MARK: - Styling
    
    func styleForUser(user: GTUser) {
        self.backgroundColor = user.followedByCurrentUser! ? AppConfig.sharedInstance.theme!.primaryColor : UIColor.whiteColor()
        followBtnTitle.textColor = user.followedByCurrentUser! ? UIColor.whiteColor() : AppConfig.sharedInstance.theme?.primaryColor
        followBtnTitle.text = user.followedByCurrentUser! ? NSLocalizedString("view_follow_button_following", comment: "") : NSLocalizedString("view_follow_button_follow", comment: "")
        followBtnImage.image = UIImage(named: user.followedByCurrentUser! ? "ic_action_unfollow" : "ic_action_follow")
        followBtnImage.tintColor = followBtnTitle.textColor
    }
    
    // MARK: - Animations
    
    func animateButton() {
        followBtnWidthConstraint.constant = followBtnTitle.frame.origin.x +
            followBtnTitle.frame.width + 15
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
        }) { finished in
            if finished {
                UIView.animateWithDuration(0.3, animations: {
                    self.followBtnTitle.alpha = 1
                }) { finished in
                    if finished {
                        Utils.runWithDelay(0.5, block: {
                            self.unAnimateButton()
                        })
                    }
                }
            }
        }
    }
    
    func unAnimateButton() {
        UIView.animateWithDuration(0.3, animations: {
            self.followBtnTitle.alpha = 0
        }) { finished in
            if finished {
                self.followBtnWidthConstraint.constant = self.frame.height
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.setNeedsUpdateConstraints()
                    self.layoutIfNeeded()
                }) { finished in
                    
                }
            }
        }
    }
}
