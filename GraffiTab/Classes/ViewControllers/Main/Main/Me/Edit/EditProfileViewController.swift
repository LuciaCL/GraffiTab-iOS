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

enum ImageType {
    case Avatar
    case Cover
}

class EditProfileViewController: BackButtonTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var firstnameField: UILabel!
    @IBOutlet weak var lastnameField: UILabel!
    @IBOutlet weak var emailField: UILabel!
    @IBOutlet weak var aboutField: UILabel!
    @IBOutlet weak var websiteField: UILabel!
    
    var user: GTUser = GTSettings.sharedInstance.user!
    var imageType: ImageType?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupImageViews()
        setupImagePicker()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController!.navigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickSave() {
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
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                DialogBuilder.showSuccessAlert("Your profile has been changed!", title: App.Title)
            }
        }, failureBlock: { (response) in
            self.view.hideActivityView()
            
            if response.reason == .BadRequest {
                DialogBuilder.showErrorAlert("This email is already used by another user.", title: App.Title)
                return
            }
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        })
    }
    
    // MARK: - Images
    
    func askForImage() {
        UIActionSheet.showInView(self.view, withTitle: "What would you like to do?", cancelButtonTitle: "Cancel", destructiveButtonTitle: "Remove image", otherButtonTitles: ["Choose from gallery", "Take new"], tapBlock: { (actionSheet, index) in
            if index == 0 {
                self.saveImage(nil)
            }
            else if index == 1 {
                self.chooseFromGallery()
            }
            else if index == 2 {
                self.takeNew()
            }
        })
    }
    
    func chooseFromGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePicker.sourceType = .PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            print("DEBUG: Source type .PhotoLibrary not available")
        }
    }
    
    func takeNew() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
        else {
            print("DEBUG: Source type .Camera not available")
        }
    }
    
    func saveImage(image: UIImage?) {
        let avatarSuccessBlock = {
            self.view.hideActivityView()
            
            self.loadAvatar()
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                DialogBuilder.showSuccessAlert("Your avatar has been changed!", title: App.Title)
            }
        }
        let coverSuccessBlock = {
            self.view.hideActivityView()
            
            self.loadCover()
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
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
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.editCover(image!, successBlock: { (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
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
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
            else {
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.deleteCover({ (response) in
                    coverSuccessBlock()
                }, failureBlock: { (response) in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title)
                })
            }
        }
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
        if user.avatar != nil {
            Alamofire.request(.GET, user.avatar!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    self.avatar.image = image
            }
        }
        else {
            avatar.image = UIImage(named: "default_avatar")!
        }
    }
    
    func loadCover() {
        if user.cover != nil {
            Alamofire.request(.GET, user.cover!.link!)
                .responseImage { response in
                    let image = response.result.value
                    
                    self.cover.image = image
            }
        }
        else {
            cover.image = nil
        }
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
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            saveImage(pickedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
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
        avatar.layer.cornerRadius = 5
        cover.layer.cornerRadius = 5
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}
