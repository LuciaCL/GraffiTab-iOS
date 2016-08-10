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
            return NSLocalizedString("api_error_unsupported_file_type", comment: "")
        }
        if self.reason == .INVALID_TOKEN {
            return NSLocalizedString("api_error_invalid_token", comment: "")
        }
        if self.reason == .STREAM_COULD_NOT_BE_READ {
            return NSLocalizedString("api_error_stream_could_not_be_read", comment: "")
        }
        if self.reason == .INVALID_ARGUMENT {
            return NSLocalizedString("api_error_invalid_argument", comment: "")
        }
        if self.reason == .MISSING_ARGUMENT {
            return NSLocalizedString("api_error_missing_argument", comment: "")
        }
        if self.reason == .INVALID_JSON {
            return NSLocalizedString("api_error_invalid_json", comment: "")
        }
        if self.reason == .INVALID_FOLLOWEE {
            return NSLocalizedString("api_error_invalid_followee", comment: "")
        }
        if self.reason == .EMPTY_MANDATORY_FIELD {
            return NSLocalizedString("api_error_empty_mandatory_field", comment: "")
        }
        if self.reason == .INVALID_USERNAME {
            return NSLocalizedString("api_error_invalid_username", comment: "")
        }
        if self.reason == .INVALID_EMAIL {
            return NSLocalizedString("api_error_invalid_email", comment: "")
        }
        if self.reason == .USERNAME_ALREADY_IN_USE {
            return NSLocalizedString("api_error_username_already_in_use", comment: "")
        }
        if self.reason == .EMAIL_ALREADY_IN_USE {
            return NSLocalizedString("api_error_email_already_in_use", comment: "")
        }
        if self.reason == .INVALID_ID {
            return NSLocalizedString("api_error_invalid_id", comment: "")
        }
        
        
        if self.reason == .USER_NOT_LOGGED_IN {
            return NSLocalizedString("api_error_user_not_logged_in", comment: "")
        }
        if self.reason == .USER_NOT_OWNER {
            return NSLocalizedString("api_error_user_not_owner", comment: "")
        }
        
        
        if self.reason == .INCORRECT_PASSWORD {
            return NSLocalizedString("api_error_incorrect_password", comment: "")
        }
        if self.reason == .MAXIMUM_LOGIN_ATTEMPTS {
            return NSLocalizedString("api_error_max_login_attempts", comment: "")
        }
        if self.reason == .FORBIDDEN_RESOURCE {
            return NSLocalizedString("api_error_forbidden", comment: "")
        }
        
        
        if self.reason == .EXTERNAL_PROVIDER_NOT_FOUND {
            return NSLocalizedString("api_error_external_provider_not_found", comment: "")
        }
        if self.reason == .EXTERNAL_PROVIDER_NOT_LINKED {
            return NSLocalizedString("api_error_external_provider_not_linked", comment: "")
        }
        if self.reason == .DEVICE_NOT_FOUND {
            return NSLocalizedString("api_error_device_not_found", comment: "")
        }
        if self.reason == .USER_NOT_FOUND {
            return NSLocalizedString("api_error_user_not_found", comment: "")
        }
        if self.reason == .ASSET_NOT_FOUND {
            return NSLocalizedString("api_error_asset_not_found", comment: "")
        }
        if self.reason == .STREAMABLE_NOT_FOUND {
            return NSLocalizedString("api_error_streamable_not_found", comment: "")
        }
        if self.reason == .COMMENT_NOT_FOUND {
            return NSLocalizedString("api_error_comment_not_found", comment: "")
        }
        if self.reason == .LOCATION_NOT_FOUND {
            return NSLocalizedString("api_error_location_not_found", comment: "")
        }
        if self.reason == .TOKEN_NOT_FOUND {
            return NSLocalizedString("api_error_token_not_found", comment: "")
        }
        
        
        if self.reason == .TOKEN_EXPIRED {
            return NSLocalizedString("api_error_token_expired", comment: "")
        }
        if self.reason == .USER_NOT_IN_EXPECTED_STATE {
            return NSLocalizedString("api_error_user_not_in_expected_state", comment: "")
        }
        
        
        if self.reason == .DEVICE_ALREADY_EXISTS {
            return NSLocalizedString("api_error_device_already_exists", comment: "")
        }
        if self.reason == .EXTERNAL_PROVIDER_ALREADY_LINKED {
            return NSLocalizedString("api_error_external_provider_already_linked", comment: "")
        }
        if self.reason == .EXTERNAL_PROVIDER_ALREADY_LINKED_FOR_OTHER_USER {
            return NSLocalizedString("api_error_external_provider_already_linked_for_another_user", comment: "")
        }
        
        
        if self.reason == .GENERAL_ERROR {
            return NSLocalizedString("api_error_general", comment: "")
        }
        
        
        if self.reason == .OTHER {
            return NSLocalizedString("api_error_other", comment: "")
        }
        
        
        return NSLocalizedString("api_error", comment: "")
    }
}
