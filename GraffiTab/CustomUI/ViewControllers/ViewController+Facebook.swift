//
//  ViewController+Facebook.swift
//  GraffiTab
//
//  Created by Georgi Christov on 17/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import CocoaLumberjack

extension UIViewController {

    func inviteFriends() {
        
    }
    
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
                    DDLogError("[\(NSStringFromClass(self.dynamicType))] Error Getting Info \(error)")
                    
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
                    DDLogError("[\(NSStringFromClass(self.dynamicType))] Error logging in \(error)")
                    
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
}
