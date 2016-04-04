//
//  LoginViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 04/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import RNActivityView
import FBSDKCoreKit
import FBSDKLoginKit
import GraffiTab_iOS_SDK

class LoginViewController: BackButtonViewController, UITextFieldDelegate {

    @IBOutlet weak var loginBtn: UIView!
    @IBOutlet weak var facebookBtn: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupLabels()
        setupButtons()
        setupTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickForgottenPassword(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickSignUp(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        let un = usernameField.text
        let pa = passwordField.text
        
        if (InputValidator.validateLogin(un!, password: pa!)) {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false

            GTUserManager.login(un!, password: pa!, successBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.3 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedIn, object: nil)
                }
            }, failureBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                if (response.reason == .AuthorizationNeeded) {
                    DialogBuilder.showErrorAlert("Invalid login credentials. Please try again.", title: App.Title)
                    return
                }
                
                DialogBuilder.showErrorAlert(response.message, title: App.Title)
            })
        }
    }
    
    @IBAction func onClickFacebookLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        loginToFacebookWithSuccess({ (userId: String, token: String) -> () in
            print("SUCCESS")
        }) { (error: NSError?) -> () in
            if error != nil {
                DialogBuilder.showErrorAlert("Facebook login is not available at the moment. Please try again later.", title: App.Title)
            }
        }
    }
    
    // MARK: - Facebook.
    
    func loginToFacebookWithSuccess(successBlock: (userId: String, token: String) -> (), andFailure failureBlock: (NSError?) -> ()) {
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            // For debugging, when we want to ensure that facebook login always happens
            FBSDKLoginManager().logOut()
        }
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                
                // Process error
                FBSDKLoginManager().logOut()
                failureBlock(error)
            }
            else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            }
            else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let grantedPermissions = Array(result.grantedPermissions).map( {"\($0)"} )
                for permission in facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                
                if allPermsGranted {
                    // Do work
                    let fbToken = result.token.tokenString
                    let fbUserID = result.token.userID
                    
                    successBlock(userId: fbUserID, token: fbToken)
                } else {
                    //The user did not grant all permissions requested
                    //Discover which permissions are granted
                    //and if you can live without the declined ones
                    
                    failureBlock(nil)
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField == usernameField) {
            passwordField .becomeFirstResponder()
        }
        else {
            onClickLogin(passwordField)
        }
        
        return true
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        facebookBtn.layer.cornerRadius = 3
        loginBtn.layer.cornerRadius = 3
    }
    
    func setupLabels() {
        let title = signUpLbl.text! as String
        let attString = NSMutableAttributedString(string: title)
        let range = (title as NSString).rangeOfString("Sign up")
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 99, green: 131, blue: 151, alpha: 1.0), range: range)
        signUpLbl.attributedText = attString;
    }
    
    func setupTextFields() {
        usernameField.attributedPlaceholder = NSAttributedString(string:usernameField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.attributedPlaceholder = NSAttributedString(string:passwordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
}
