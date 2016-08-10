//
//  InputValidator.swift
//  MassAlert
//
//  Created by Georgi Christov on 27/01/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class InputValidator: NSObject {

    class func validateLogin(controller: UIViewController, username: String, password: String) -> Bool {
        if (username.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_username", comment: ""), title: App.Title)
            return false
        }
        if (password.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_password", comment: ""), title: App.Title)
            return false
        }
        
        return true
    }
    
    class func validateSignUp(controller: UIViewController, firstName: String, lastName: String, email: String, username: String, password: String, confirmPassword: String) -> Bool {
        if (firstName.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_firstname", comment: ""), title: App.Title)
            return false
        }
        if (lastName.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_lastname", comment: ""), title: App.Title)
            return false
        }
        if (email.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_email", comment: ""), title: App.Title)
            return false
        }
        if (username.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_username", comment: ""), title: App.Title)
            return false
        }
        if (password.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_password", comment: ""), title: App.Title)
            return false
        }
        if (confirmPassword.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_confirm_password", comment: ""), title: App.Title)
            return false
        }
        if (password != confirmPassword) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_password_mismatch", comment: ""), title: App.Title)
            return false
        }
        
        return true
    }
    
    class func validateEditPassword(controller: UIViewController, password: String, newPassword: String, confirmPassword: String) -> Bool {
        if (password.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_password", comment: ""), title: App.Title)
            return false
        }
        if (newPassword.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_login_new_password", comment: ""), title: App.Title)
            return false
        }
        if (confirmPassword.characters.count <= 0) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_confirm_password", comment: ""), title: App.Title)
            return false
        }
        if (newPassword != confirmPassword) {
            DialogBuilder.showErrorAlert(controller, status: NSLocalizedString("validation_sign_up_password_mismatch", comment: ""), title: App.Title)
            return false
        }
        
        return true
    }
}
