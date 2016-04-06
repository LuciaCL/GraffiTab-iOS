//
//  InputValidator.swift
//  MassAlert
//
//  Created by Georgi Christov on 27/01/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class InputValidator: NSObject {

    class func validateLogin(username: String, password: String) -> Bool {
        if (username.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter a username.", title: App.Title)
            return false
        }
        if (password.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter a password.", title: App.Title)
            return false
        }
        
        return true
    }
    
    class func validateSignUp(firstName: String, lastName: String, email: String, username: String, password: String, confirmPassword: String) -> Bool {
        if (firstName.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter your first name.", title: App.Title)
            return false
        }
        if (lastName.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter your last name.", title: App.Title)
            return false
        }
        if (email.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter an email address.", title: App.Title)
            return false
        }
        if (username.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter a username.", title: App.Title)
            return false
        }
        if (password.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter a password.", title: App.Title)
            return false
        }
        if (confirmPassword.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please confirm your password.", title: App.Title)
            return false
        }
        if (password != confirmPassword) {
            DialogBuilder.showErrorAlert("Your passwords do not match.", title: App.Title)
            return false
        }
        
        return true
    }
}
