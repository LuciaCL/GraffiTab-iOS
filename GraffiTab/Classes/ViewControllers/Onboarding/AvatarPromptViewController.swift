//
//  AvatarPromptViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 29/07/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import AHKActionSheet
import GraffiTab_iOS_SDK

class AvatarPromptViewController: BackButtonViewController {

    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sayCheeseBtn: UIButton!
    @IBOutlet weak var laterBtn: UIButton!
    
    var dismissHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupAvatar()
        setupButtons()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.avatarPromptStatusBarStyle!, animated: true)
    }
    
    @IBAction func onClickPicture(sender: AnyObject) {
        askForImage()
    }
    
    @IBAction func onClickSkip(sender: AnyObject!) {
        if dismissHandler != nil {
            dismissHandler!()
        }
    }
    
    // MARK: - Loading
    
    func loadData() {
        name.text = GTMeManager.sharedInstance.loggedInUser?.getFullName()
    }
    
    // MARK: - Images
    
    override func buildActionSheet(title: String?) -> AHKActionSheet {
        let user = GTMeManager.sharedInstance.loggedInUser
        let actionSheet = super.buildActionSheet(NSLocalizedString("controller_avatar_prompt_picture_source", comment: ""))
        
        actionSheet.addButtonWithTitle(NSLocalizedString("controller_avatar_prompt_import_from_facebook", comment: ""), image: UIImage(named: "facebook"), type: user!.isLinkedAccount(.FACEBOOK) ? .Default : .Disabled) { (sheet) in
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3) { () in
                    self.onClickSkip(nil)
                }
            }, failureBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
        
        return actionSheet
    }
    
    override func didChooseImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            Utils.runWithDelay(0.3) { () in
                self.onClickSkip(nil)
            }
        }
        
        if image != nil { // Saving a new image.
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.editAvatar(image!, successBlock: { (response) in
                avatarSuccessBlock()
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
        else { // Removing an image.
            self.view.showActivityView()
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.deleteAvatar({ (response) in
                avatarSuccessBlock()
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
    }
    
    override func cropAspectRatio() -> CGSize {
        let width = CGFloat(300);
        let height = width;
        
        return CGSizeMake(width, width / (width / height))
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if DeviceType.IS_IPAD {
            return .All
        }
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: - Setup
    
    func setupAvatar() {
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 3
    }
    
    func setupButtons() {
        sayCheeseBtn.layer.cornerRadius = 3
        sayCheeseBtn.setTitle(NSLocalizedString("controller_avatar_prompt_say_cheese", comment: ""), forState: .Normal)
        laterBtn.setTitle(NSLocalizedString("controller_avatar_prompt_later", comment: ""), forState: .Normal)
    }
}
