//
//  EditPasswordViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

class EditPasswordViewController: BackButtonTableViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        passwordField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickSave() {
        self.view.endEditing(true)
        
        let p = passwordField.text
        let np = newPasswordField.text
        let cp = confirmPasswordField.text
        
        if InputValidator.validateEditPassword(p!, newPassword: np!, confirmPassword: cp!) {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTMeManager.editPassword(p!, newPassword: np!, successBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert("Your password has been changed!", title: App.Title, okAction: {
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                if (response.reason == .Forbidden) {
                    DialogBuilder.showErrorAlert("Your password is incorrect. Please try again.", title: App.Title)
                    
                    return
                }
                
                DialogBuilder.showErrorAlert(response.message, title: App.Title)
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
        
        self.title = "Edit password"
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle("Save", forState: .Normal)
        button.backgroundColor = UIColor(hexString: Colors.Orange)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditPasswordViewController.onClickSave), forControlEvents: .TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
}