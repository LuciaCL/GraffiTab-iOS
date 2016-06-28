//
//  ResetPasswordViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CocoaLumberjack

class ResetPasswordViewController: BackButtonViewController, UITextFieldDelegate {

    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        
        configureCharacterBasedViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    @IBAction func onTextChanged(sender: AnyObject) {
        configureCharacterBasedViews()
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickReset(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting password reset")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("reset_password", label: nil)
        
        self.view.endEditing(true)
        
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        let successHandler = {
            DialogBuilder.showSuccessAlert("We have sent an email to the specified email address if it exists. Please check it for instructions on how to reset your password.", title: App.Title, okAction: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
        GTUserManager.resetPassword(emailField.text!, successBlock: { (response) in
            self.view.hideActivityView()
            
            successHandler()
        }) { (response) in
            self.view.hideActivityView()
            
            if (response.reason != .NotFound) {
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
                return
            }
            
            successHandler()
        }
    }
    
    func configureCharacterBasedViews() {
        if emailField.text?.characters.count <= 0 { // Disable Send button.
            let tint = UIColor(hexString: "#e0e0e0")
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.resetBtn.enabled = false
                self.resetBtn.backgroundColor = UIColor.clearColor()
                self.resetBtn.layer.borderColor = tint!.CGColor
                self.resetBtn.layer.borderWidth = 1
                self.resetBtn.setTitleColor(tint, forState: .Normal)
            })
        }
        else { // Enable Send button.
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.resetBtn.enabled = true
                self.resetBtn.backgroundColor = UIColor(hexString: Colors.Orange)
                self.resetBtn.layer.borderWidth = 0
                self.resetBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            })
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        resetBtn.layer.cornerRadius = 3
    }
}
