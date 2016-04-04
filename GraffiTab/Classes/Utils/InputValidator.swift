//
//  InputValidator.swift
//  MassAlert
//
//  Created by Georgi Christov on 27/01/2016.
//  Copyright © 2016 Futurist Labs. All rights reserved.
//

import UIKit

class InputValidator: NSObject {

    class func validateLogin(domain: String, username: String, password: String) -> Bool {
        if (domain.characters.count <= 0) {
            DialogBuilder.showErrorAlert("Please enter a domain.", title: App.Title)
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
        
        return true
    }}
