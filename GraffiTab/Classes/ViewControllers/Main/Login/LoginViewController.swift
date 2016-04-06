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
    
    @IBAction func onClickSignUp(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func onClickLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        login()
    }
    
    @IBAction func onClickFacebookLogin(sender: AnyObject) {
        self.view.endEditing(true)
        
        loginFacebook(true)
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
            print("DEBUG: Signed up successfully. Attempting login..")
            
            self.loginFacebook(false)
        }) { (response) -> Void in
            self.view.hideActivityView()
            
            if (response.reason == .BadRequest || response.reason == .AlreadyExists) {
                DialogBuilder.showErrorAlert("A user with these details already exists.", title: App.Title)
                return
            }
            
            DialogBuilder.showErrorAlert(response.message, title: App.Title)
        }
    }
    
    func finishExternalProviderSignup(askToImportAvatar: Bool) {
        let avatarImportHandler = {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.UserLoggedIn, object: nil)
            }
        }
        
        if askToImportAvatar {
            DialogBuilder.showYesNoSuccessAlert("You have successfully registered with Facebook. Would you like to import your profile picture?", title: App.Title, yesTitle: "Import it!", noTitle: "Later", yesAction: { () -> Void in
                self.view.showActivityViewWithLabel("Processing")
                self.view.rn_activityView.dimBackground = false
                
                GTUserManager.importAvatar(.FACEBOOK, successBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    avatarImportHandler()
                }, failureBlock: { (response) -> Void in
                    self.view.hideActivityView()
                    
                    DialogBuilder.showErrorAlert(response.message, title: App.Title, okAction: {
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
    
    func loginFacebook(forceLogin: Bool) {
        self.view.showActivityViewWithLabel("Processing")
        self.view.rn_activityView.dimBackground = false
        
        loginToFacebookWithSuccess(forceLogin, successBlock: { (userId: String, token: String, email: String, firstName: String, lastName: String) -> () in
            print("DEBUG: Facebook permissions granted. Read parameters:")
            print("DEBUG: User ID: \(userId)")
            print("DEBUG: User email: \(email)")
            print("DEBUG: User first name: \(firstName)")
            print("DEBUG: User last name: \(lastName)")
            print("DEBUG: Access token: \(token)")
            
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
                
                DialogBuilder.showErrorAlert(response.message, title: App.Title)
            })
        }) { (error: NSError?) -> () in
            self.view.hideActivityView()
            
            if error != nil {
                DialogBuilder.showErrorAlert("Facebook login is not available at the moment. Please try again later.", title: App.Title)
            }
        }
    }
    
    // MARK: - Facebook.
    
    func loginToFacebookWithSuccess(forceLogin: Bool, successBlock: (userId: String, token: String, email: String, firstName: String, lastName: String) -> (), andFailure failureBlock: (NSError?) -> ()) {
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        
        if forceLogin == true {
            FBSDKLoginManager().logOut()
        }
        
        let fbSuccessHandler = {(token: String, userId: String) -> () in
            // Get user details.
            let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: ["fields":"id, email, first_name, last_name"]);
            fbRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                
                if error == nil {
                    let email = result.valueForKey("email") as! String
                    let firstName = result.valueForKey("first_name") as! String
                    let lastName = result.valueForKey("last_name") as! String
                    successBlock(userId: userId, token: token, email: email, firstName: firstName, lastName: lastName)
                }
                else {
                    print("DEBUG: Error Getting Info \(error)");
                    failureBlock(error)
                }
            }
        }
        
        if FBSDKAccessToken.currentAccessToken() != nil { // We already have a token, so use it to login.
            let token = FBSDKAccessToken.currentAccessToken()
            let fbToken = token.tokenString
            let fbUserID = token.userID
            
            fbSuccessHandler(fbToken, fbUserID)
        }
        else { // No token yet or it has been cleared, so obtain a new token.
            FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: self) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                if error != nil {
                    //According to Facebook:
                    //Errors will rarely occur in the typical login flow because the login dialog
                    //presented by Facebook via single sign on will guide the users to resolve any errors.
                    
                    // Process error
                    FBSDKLoginManager().logOut()
                    print("DEBUG: Error logging in \(error)");
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
                        
                        fbSuccessHandler(fbToken, fbUserID)
                    } else {
                        //The user did not grant all permissions requested
                        //Discover which permissions are granted
                        //and if you can live without the declined ones
                        
                        failureBlock(nil)
                    }
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
