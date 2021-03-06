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
import MZFormSheetPresentationController

enum ImageType {
    case Avatar
    case Cover
}

class EditProfileViewController: BackButtonTableViewController {

    @IBOutlet weak var avatarLbl: UILabel!
    @IBOutlet weak var coverLbl: UILabel!
    @IBOutlet weak var changePasswordLbl: UILabel!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var privateGraffitiLbl: UILabel!
    @IBOutlet weak var avatar: AvatarImageView!
    @IBOutlet weak var cover: CoverImageView!
    @IBOutlet weak var firstnameField: UILabel!
    @IBOutlet weak var lastnameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var aboutField: UILabel!
    @IBOutlet weak var websiteField: UILabel!
    
    var user: GTUser = GTMeManager.sharedInstance.loggedInUser!
    var imageType: ImageType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
        setupImageViews()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(AppConfig.sharedInstance.theme!.defaultStatusBarStyle!, animated: true)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
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
        
        self.view.showActivityView()
        self.view.rn_activityView.dimBackground = false
        
        GTMeManager.editProfile(fn!, lastName: ln!, email: e!, about: a, website: w, successBlock: { (response) in
            self.view.hideActivityView()
            
            self.user = GTMeManager.sharedInstance.loggedInUser!
            self.loadData()
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }, failureBlock: { (response) in
            self.view.hideActivityView()
            
            DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
        })
    }
    
    // MARK: - Images
    
    override func buildActionSheet(title: String?) -> AHKActionSheet {
        let actionSheet = super.buildActionSheet(title)
        if imageType == .Avatar {
            actionSheet.addButtonWithTitle(NSLocalizedString("controller_avatar_prompt_import_from_facebook", comment: ""), image: UIImage(named: "facebook"), type: self.user.isLinkedAccount(.FACEBOOK) ? .Default : .Disabled) { (sheet) in
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                // Register analytics events.
                AnalyticsUtils.sendAppEvent("profile_import_facebook_avatar", label: nil)
                
                GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    self.loadAvatar()
                    
                    Utils.runWithDelay(0.3) { () in
                        DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_avatar_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
                    }
                }, failureBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_avatar_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }
        let coverSuccessBlock = {
            self.view.hideActivityView()
            
            self.loadCover()
            
            Utils.runWithDelay(0.3) { () in
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_profile_cover_success", comment: ""), title: NSLocalizedString("other_success", comment: ""))
            }
        }
        
        if image != nil { // Saving a new image.
            if imageType == .Avatar {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editAvatar(image!, successBlock: { (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
            else {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editCover(image!, successBlock: { (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
        }
        else { // Removing an image.
            if imageType == .Avatar {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteAvatar({ (response) in
                    avatarSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
                })
            }
            else {
                self.view.showActivityView()
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteCover({ (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                EditPasswordViewController.showPasswordEditController(self)
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                EditTextFieldViewController.showEditFieldController(self, doneBlock: { (value) in
                    self.firstnameField.text = value
                }, defaultValue: firstnameField.text!, allowEmpty: false, capitalizationType: .Words, keyboardType: .Default)
            }
            else if indexPath.row == 1 {
                EditTextFieldViewController.showEditFieldController(self, doneBlock: { (value) in
                    self.lastnameField.text = value
                }, defaultValue: lastnameField.text!, allowEmpty: false, capitalizationType: .Words, keyboardType: .Default)
            }
            else if indexPath.row == 2 {
                EditTextFieldViewController.showEditFieldController(self, doneBlock: { (value) in
                    self.emailField.text = value
                }, defaultValue: emailField.text!, allowEmpty: false, capitalizationType: .None, keyboardType: .EmailAddress)
            }
            else if indexPath.row == 3 {
                EditTextViewController.showEditFieldController(self, doneBlock: { (value) in
                    self.aboutField.text = value
                    }, defaultValue: aboutField.text != nil ? aboutField.text! : "", allowEmpty: true, capitalizationType: .Sentences, keyboardType: .Default)
            }
            else if indexPath.row == 4 {
                EditTextFieldViewController.showEditFieldController(self, doneBlock: { (value) in
                    self.websiteField.text = value
                }, defaultValue: websiteField.text != nil ? websiteField.text! : "", allowEmpty: true, capitalizationType: .None, keyboardType: .URL)
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 3 {
            return NSLocalizedString("controller_edit_profile_private_graffiti_title", comment: "")
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 {
            return NSLocalizedString("controller_edit_profile_private_graffiti_description", comment: "")
        }
        
        return nil
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("controller_edit_profile", comment: "")
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle(NSLocalizedString("other_save", comment: ""), forState: .Normal)
        button.backgroundColor = AppConfig.sharedInstance.theme!.primaryColor
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditProfileViewController.onClickSave), forControlEvents: .TouchUpInside)
        button.sizeToFit()
        button.frame = CGRectMake(0, 0, button.frame.width + 10, 30)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
    
    func setupImageViews() {
        cover.layer.cornerRadius = 5
    }
    
    func setupLabels() {
        avatarLbl.text = NSLocalizedString("controller_edit_profile_avatar", comment: "")
        coverLbl.text = NSLocalizedString("controller_edit_profile_cover", comment: "")
        changePasswordLbl.text = NSLocalizedString("controller_settings_change_password", comment: "")
        firstNameLbl.text = NSLocalizedString("controller_sign_up_first_name", comment: "")
        lastNameLbl.text = NSLocalizedString("controller_sign_up_last_name", comment: "")
        emailLbl.text = NSLocalizedString("controller_pasword_reset_email", comment: "")
        aboutLbl.text = NSLocalizedString("controller_edit_profile_about", comment: "")
        websiteLbl.text = NSLocalizedString("controller_edit_profile_website", comment: "")
        privateGraffitiLbl.text = NSLocalizedString("controller_edit_profile_private_graffiti", comment: "")
    }
}
