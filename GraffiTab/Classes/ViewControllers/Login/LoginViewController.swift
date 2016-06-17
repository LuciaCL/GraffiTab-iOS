//
//  LoginViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 04/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import RNActivityView
import GraffiTab_iOS_SDK
import CocoaLumberjack

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
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        login()
    }
    
    @IBAction func onClickFacebookLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Logging in with Facebook")
        
        loginFacebook(true)
    }
    
    @IBAction func onClickDevOptions(sender: AnyObject) {
        let vc = UIStoryboard(name: "DeveloperOptionsStoryboard", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    // MARK: - Loading
    
    func loadData() {
        if Settings.sharedInstance.rememberCredentials! {
            usernameField.text = Settings.sharedInstance.username
            passwordField.text = Settings.sharedInstance.password
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Sign up
    
    func signUpWithFacebook(userId: String, token: String, email: String, firstName: String, lastName: String, username: String) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        GTUserManager.register(.FACEBOOK, externalId: userId, accessToken: token, email: email, firstName: firstName, lastName: lastName, username: username, successBlock: { (response) -> Void in
            self.view.hideActivityView()
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Signed up successfully. Attempting login")
            
            self.loginFacebook(false)
        }) { (response) -> Void in
            self.view.hideActivityView()
            
            if (response.reason == .BadRequest || response.reason == .AlreadyExists) {
                DialogBuilder.showAPIErrorAlert("A user with these details already exists.", title: App.Title, forceShow: true)
                return
            }
            
            DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
        }
    }
    
    func finishExternalProviderSignup(askToImportAvatar: Bool) {
        let avatarImportHandler = {
            Utils.runWithDelay(1.3) { () in
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedIn, object: nil)
            }
        }
        
        if askToImportAvatar {
            DialogBuilder.showYesNoSuccessAlert("You have successfully registered with Facebook. Would you like to import your profile picture?", title: App.Title, yesTitle: "Import it!", noTitle: "Later", yesAction: { () -> Void in
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTMeManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    avatarImportHandler()
                }, failureBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true, okAction: {
                        avatarImportHandler()
                    })
                })
            }) { () -> Void in
                avatarImportHandler()
            }
        }
        else {
            avatarImportHandler()
        }
    }
    
    // MARK: - Login
    
    func login() {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting user login")
        
        let un = usernameField.text
        let pa = passwordField.text
        
        if (InputValidator.validateLogin(un!, password: pa!)) {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTUserManager.login(un!, password: pa!, successBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                // TODO: Add these to security chain.
                Settings.sharedInstance.username = un
                Settings.sharedInstance.password = pa
                
                Utils.runWithDelay(1.3) { () in
                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedIn, object: nil)
                }
            }, failureBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                if (response.reason == .AuthorizationNeeded) {
                    DialogBuilder.showAPIErrorAlert("Invalid login credentials. Please try again.", title: App.Title, forceShow: true)
                    return
                }
                
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
            })
        }
    }
    
    func loginFacebook(forceLogin: Bool) {
        DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Attempting user Facebook login")
        
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        loginToFacebookWithSuccess(forceLogin, successBlock: { (userId: String, token: String, email: String, firstName: String, lastName: String) -> () in
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Facebook permissions granted.")
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User ID: \(userId)")
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User email: \(email)")
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User first name: \(firstName)")
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] User last name: \(lastName)")
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Access token: \(token)")
            
            // Attempt login with external provider.
            GTUserManager.login(.FACEBOOK, externalId: userId, accessToken: token, successBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                // Login with external provider is successful at this point.
                // If forceLogin is false, this means that the user is registering with external provider, so ask if they want to import their avatar.
                self.finishExternalProviderSignup(!forceLogin)
            }, failureBlock: { (response) -> Void in
                self.view.hideActivityView()
                
                if (response.reason == .AuthorizationNeeded) { // This error means that thre isn't a user with those external credentials.
                    DialogBuilder.showInputUsername(okAction: { (username) -> Void in
                        self.signUpWithFacebook(userId, token: token, email: email, firstName: firstName, lastName: lastName, username: username)
                    }, cancelAction: {})
                    
                    return
                }
                
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
            })
        }) { (error: NSError?) -> () in
            self.view.hideActivityView()
            
            if error != nil {
                DialogBuilder.showErrorAlert("Facebook login is not available at the moment. Please try again later.", title: App.Title)
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
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
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
        usernameField.attributedPlaceholder = NSAttributedString(string:usernameField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        passwordField.attributedPlaceholder = NSAttributedString(string:passwordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
    }
}
