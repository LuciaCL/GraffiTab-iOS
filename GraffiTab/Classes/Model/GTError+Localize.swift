//
//  GTError+Localize.swift
//  GraffiTab
//
//  Created by Georgi Christov on 31/07/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK

extension GTError {

    func localizedMessage() -> String {
        if self.reason == .UNSUPPORTED_FILE_TYPE {
            return "This file type is not supported."
        }
        if self.reason == .INVALID_TOKEN {
            return "The provided token is invalid."
        }
        if self.reason == .STREAM_COULD_NOT_BE_READ {
            return "The file stream could not be read."
        }
        if self.reason == .INVALID_ARGUMENT {
            return "Invalid argument passed in the request."
        }
        if self.reason == .MISSING_ARGUMENT {
            return "Missing argument in the request."
        }
        if self.reason == .INVALID_JSON {
            return "Invalid JSON in the request."
        }
        if self.reason == .INVALID_FOLLOWEE {
            return "You cannot follow yourself."
        }
        if self.reason == .EMPTY_MANDATORY_FIELD {
            return "Mandatory fields missing."
        }
        if self.reason == .INVALID_USERNAME {
            return "This username is invalid."
        }
        if self.reason == .INVALID_EMAIL {
            return "This email is invalid."
        }
        if self.reason == .USERNAME_ALREADY_IN_USE {
            return "This username already exists."
        }
        if self.reason == .EMAIL_ALREADY_IN_USE {
            return "This email already exists."
        }
        if self.reason == .INVALID_ID {
            return "You cannot pass ID to create request."
        }
        
        
        if self.reason == .USER_NOT_LOGGED_IN {
            return "Your session has expired. Please login to continue."
        }
        if self.reason == .USER_NOT_OWNER {
            return "You do not have permission to edit this item."
        }
        
        
        if self.reason == .INCORRECT_PASSWORD {
            return "Your password is incorrect. Please try again."
        }
        if self.reason == .MAXIMUM_LOGIN_ATTEMPTS {
            return "Maximum login attempts have been reached. Please reset your password to continue."
        }
        if self.reason == .FORBIDDEN_RESOURCE {
            return "This resource is forbidden."
        }
        
        
        if self.reason == .EXTERNAL_PROVIDER_NOT_FOUND {
            return "This external provider does not exist."
        }
        if self.reason == .EXTERNAL_PROVIDER_NOT_LINKED {
            return "This external provider has not been linked."
        }
        if self.reason == .DEVICE_NOT_FOUND {
            return "The requested device does not exist."
        }
        if self.reason == .USER_NOT_FOUND {
            return "The requested user does not exist."
        }
        if self.reason == .ASSET_NOT_FOUND {
            return "This asset does not exist."
        }
        if self.reason == .STREAMABLE_NOT_FOUND {
            return "This item does not exist."
        }
        if self.reason == .COMMENT_NOT_FOUND {
            return "This comment does not exist."
        }
        if self.reason == .LOCATION_NOT_FOUND {
            return "This location does not exist."
        }
        if self.reason == .TOKEN_NOT_FOUND {
            return "This token does not exist."
        }
        
        
        if self.reason == .TOKEN_EXPIRED {
            return "The provided token has expired."
        }
        if self.reason == .USER_NOT_IN_EXPECTED_STATE {
            return "Your account is not in the expected state. Please reset your password or login to continue."
        }
        
        
        if self.reason == .DEVICE_ALREADY_EXISTS {
            return "This device already exists."
        }
        if self.reason == .EXTERNAL_PROVIDER_ALREADY_LINKED {
            return "This external provider has already been linked."
        }
        if self.reason == .EXTERNAL_PROVIDER_ALREADY_LINKED_FOR_OTHER_USER {
            return "This external provider has already been linked for another user."
        }
        
        
        if self.reason == .GENERAL_ERROR {
            return "An unexpected error has ocurred. Please contast support to raise a ticket."
        }
        
        
        if self.reason == .OTHER {
            return "Looks like we're experiencing some errors processing your request. Make sure you're Internet connection is working and try again. Otherwise please check our status page for more information."
        }
        
        
        return "An unexpected error has ocurred. Please contast support to raise a ticket."
    }
}
