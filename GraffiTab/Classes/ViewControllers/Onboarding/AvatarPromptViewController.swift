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

class AvatarPromptViewController: UIViewController {

    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sayCheeseBtn: UIButton!
    
    var dismissHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupAvatar()
        setupButtons()
        
        loadData()
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
        let actionSheet = super.buildActionSheet("Choose a source for your profile picture")
        
        actionSheet.addButtonWithTitle("Import from Facebook", image: UIImage(named: "facebook"), type: user!.isLinkedAccount(.FACEBOOK) ? .Default : .Disabled) { (sheet) in
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                Utils.runWithDelay(0.3) { () in
                    self.onClickSkip(nil)
                }
            }, failureBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.editAvatar(image!, successBlock: { (response) in
                avatarSuccessBlock()
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
        else { // Removing an image.
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.deleteAvatar({ (response) in
                avatarSuccessBlock()
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: - Setup
    
    func setupAvatar() {
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 3
    }
    
    func setupButtons() {
        sayCheeseBtn.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        sayCheeseBtn.layer.borderWidth = 1
        sayCheeseBtn.layer.cornerRadius = 3
    }
}
