//
//  EditPasswordViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CocoaLumberjack

class EditPasswordViewController: BackButtonTableViewController, UITextFieldDelegate {

    @IBOutlet weak var yourPasswordLbl: UILabel!
    @IBOutlet weak var newPasswordLbl: UILabel!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordField.becomeFirstResponder()
    }

    func onClickSave() {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to change password")
        
        self.view.endEditing(true)
        
        let p = passwordField.text
        let np = newPasswordField.text
        let cp = confirmPasswordField.text
        
        if InputValidator.validateEditPassword(self, password: p!, newPassword: np!, confirmPassword: cp!) {
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("profile_change_password", label: nil)
            
            self.view.showActivityViewWithLabel(NSLocalizedString("other_processing", comment: ""))
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.editPassword(p!, newPassword: np!, successBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_edit_password_success", comment: ""), title: App.Title, okAction: {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
            })
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordField {
            newPasswordField.becomeFirstResponder()
        }
        else if textField == newPasswordField {
            confirmPasswordField.becomeFirstResponder()
        }
        else {
            confirmPasswordField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("controller_edit_password", comment: "")
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle(NSLocalizedString("other_save", comment: ""), forState: .Normal)
        button.backgroundColor = AppConfig.sharedInstance.theme!.primaryColor
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditPasswordViewController.onClickSave), forControlEvents: .TouchUpInside)
        button.sizeToFit()
        button.frame = CGRectMake(0, 0, button.frame.width + 10, 30)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
    
    func setupLabels() {
        yourPasswordLbl.text = NSLocalizedString("controller_edit_password_your", comment: "")
        newPasswordLbl.text = NSLocalizedString("controller_edit_password_new", comment: "")
        confirmPasswordLbl.text = NSLocalizedString("controller_edit_password_confirm", comment: "")
    }
}
