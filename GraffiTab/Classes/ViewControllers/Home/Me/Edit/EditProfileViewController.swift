//
//  EditProfileViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Alamofire
import GraffiTab_iOS_SDK
import CocoaLumberjack
import AHKActionSheet

enum ImageType {
    case Avatar
    case Cover
}

class EditProfileViewController: BackButtonTableViewController {

    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var cover: CoverImageView!
    @IBOutlet weak var firstnameField: UILabel!
    @IBOutlet weak var lastnameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var aboutField: UILabel!
    @IBOutlet weak var websiteField: UILabel!
    
    var user: GTUser = GTSettings.sharedInstance.user!
    var imageType: ImageType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImageViews()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickSave() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to save profile")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("profile_edit", label: nil)
        
        let fn = firstnameField.text
        let ln = lastnameField.text
        let e = emailField.text
        var a = aboutField.text
        var w = websiteField.text
        
        if a?.characters.count <= 0 {
            a = nil
        }
        if w?.characters.count <= 0 {
            w = nil
        }
        
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        GTMeManager.editProfile(fn!, lastName: ln!, email: e!, about: a, website: w, successBlock: { (response) in
            self.view.hideActivityView()
            
            self.user = GTSettings.sharedInstance.user!
            self.loadData()
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert("Your profile has been changed!", title: App.Title)
            }
        }, failureBlock: { (response) in
            self.view.hideActivityView()
            
            if response.reason == .BadRequest {
                DialogBuilder.showAPIErrorAlert("This email is already used by another user.", title: App.Title, forceShow: true)
                return
            }
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
        })
    }
    
    // MARK: - Images
    
    override func buildActionSheet(title: String?) -> AHKActionSheet {
        let actionSheet = super.buildActionSheet(title)
        if imageType == .Avatar {
            actionSheet.addButtonWithTitle("Import from Facebook", image: UIImage(named: "facebook"), type: self.user.isLinkedAccount(.FACEBOOK) ? .Default : .Disabled) { (sheet) in
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("profile_import_facebook_avatar", label: nil)
                
                GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    self.loadAvatar()
                    
                    Utils.runWithDelay(0.3) { () in
                        DialogBuilder.showSuccessAlert("Your avatar has been changed!", title: App.Title)
                    }
                }, failureBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }
        }
        return actionSheet
    }
    
    override func didChooseImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            self.loadAvatar()
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert("Your avatar has been changed!", title: App.Title)
            }
        }
        let coverSuccessBlock = {
            self.view.hideActivityView()
            
            self.loadCover()
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert("Your cover has been changed!", title: App.Title)
            }
        }
        
        if image != nil { // Saving a new image.
            if imageType == .Avatar {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editAvatar(image!, successBlock: { (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editCover(image!, successBlock: { (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }
        }
        else { // Removing an image.
            if imageType == .Avatar {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteAvatar({ (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteCover({ (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                })
            }
        }
    }
    
    override func cropAspectRatio() -> CGSize {
        let width = CGFloat(imageType == .Avatar ? 300 : 1024);
        let height = imageType == .Avatar ? width : 768;
        
        return CGSizeMake(width, width / (width / height))
    }
    
    // MARK: - Loading
    
    func loadData() {
        firstnameField.text = user.firstName
        lastnameField.text = user.lastName
        emailField.text = user.email
        aboutField.text = user.about
        websiteField.text = user.website
        
        loadAvatar()
        loadCover()
    }
    
    func loadAvatar() {
        self.avatar.asset = user.avatar
    }
    
    func loadCover() {
        self.cover.asset = user.cover
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_EDIT_FIRSTNAME" {
            let vc = segue.destinationViewController as! EditTextFieldViewController
            vc.capitalizationType = .Words
            vc.allowEmpty = false
            vc.defaultValue = firstnameField.text
            vc.doneBlock = { (value) in
                self.firstnameField.text = value
            }
        }
        else if segue.identifier == "SEGUE_EDIT_LASTNAME" {
            let vc = segue.destinationViewController as! EditTextFieldViewController
            vc.capitalizationType = .Words
            vc.allowEmpty = false
            vc.defaultValue = lastnameField.text
            vc.doneBlock = { (value) in
                self.lastnameField.text = value
            }
        }
        else if segue.identifier == "SEGUE_EDIT_EMAIL" {
            let vc = segue.destinationViewController as! EditTextFieldViewController
            vc.keyboardType = .EmailAddress
            vc.allowEmpty = false
            vc.defaultValue = emailField.text
            vc.doneBlock = { (value) in
                self.emailField.text = value
            }
        }
        else if segue.identifier == "SEGUE_EDIT_WEBSITE" {
            let vc = segue.destinationViewController as! EditTextFieldViewController
            vc.keyboardType = .EmailAddress
            vc.allowEmpty = true
            vc.defaultValue = websiteField.text
            vc.doneBlock = { (value) in
                self.websiteField.text = value
            }
        }
        else if segue.identifier == "SEGUE_EDIT_ABOUT" {
            let vc = segue.destinationViewController as! EditTextViewController
            vc.capitalizationType = .Sentences
            vc.allowEmpty = true
            vc.defaultValue = aboutField.text
            vc.doneBlock = { (value) in
                self.aboutField.text = value
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                imageType = .Avatar
                askForImage()
            }
            else {
                imageType = .Cover
                askForImage()
            }
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Edit profile"
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle("Save", forState: .Normal)
        button.backgroundColor = UIColor(hexString: Colors.Orange)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditProfileViewController.onClickSave), forControlEvents: .TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
    
    func setupImageViews() {
        cover.layer.cornerRadius = 5
    }
}
