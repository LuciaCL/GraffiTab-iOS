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
    @IBOutlet weak var resetPasswordLbl: UILabel!
    @IBOutlet weak var resetPasswordDescriptionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
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
        
        self.view.showActivityView()
        self.view.rn_activityView.dimBackground = false
        
        let successHandler = {
            DialogBuilder.showSuccessAlert(self, status: NSLocalizedString("controller_pasword_reset_confirmation", comment: ""), title: NSLocalizedString("other_success", comment: ""), okAction: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
        GTUserManager.resetPassword(emailField.text!, successBlock: { (response) in
            self.view.hideActivityView()
            
            successHandler()
        }) { (response) in
            self.view.hideActivityView()
            
            if (response.error.reason != .USER_NOT_FOUND) {
                DialogBuilder.showAPIErrorAlert(self, status: response.error.localizedMessage(), title: App.Title, forceShow: true, reason: response.error.reason)
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
                self.resetBtn.backgroundColor = AppConfig.sharedInstance.theme!.primaryColor
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
        if DeviceType.IS_IPAD {
            return .All
        }
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        resetBtn.setTitle(NSLocalizedString("controller_pasword_reset_reset", comment: ""), forState: .Normal)
        resetBtn.layer.cornerRadius = 3
    }
    
    func setupLabels() {
        resetPasswordLbl.text = NSLocalizedString("controller_pasword_reset", comment: "")
        resetPasswordDescriptionLbl.text = NSLocalizedString("controller_pasword_reset_description", comment: "")
        emailField.placeholder = NSLocalizedString("controller_pasword_reset_email", comment: "")
        
        resetPasswordLbl.font = resetPasswordLbl.font.fontWithSize(DeviceType.IS_IPAD ? 34 : 28)
        resetPasswordDescriptionLbl.font = resetPasswordDescriptionLbl.font.fontWithSize(DeviceType.IS_IPAD ? 18 : 13)
    }
}
