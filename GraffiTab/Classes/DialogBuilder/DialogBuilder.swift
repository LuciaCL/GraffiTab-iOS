//
//  DialogBuilder.swift
//  kv-app-tv
//
//  Created by Georgi Christov on 09/11/2015.
//  Copyright © 2015 Qumu Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class DialogBuilder: NSObject {

    static var lastErrorDate: NSDate?
    
    class func showOKAlert(status: String, title: String) {
        self.showOKAlert(status, title: title, okAction: {})
    }
    
    class func showOKAlert(status: String, title: String, okAction:() -> Void) {
        let alertView = buildOKAlert(status, title: title, okAction: okAction)
        alertView.showInfo(title, subTitle: status)
    }
    
    class func showSuccessAlert(status: String, title: String) {
        let alertView = buildOKAlert(status, title: title, okAction: {})
        alertView.showSuccess(title, subTitle: status)
    }
    
    class func showSuccessAlert(status: String, title: String, okAction:() -> Void) {
        let alertView = buildOKAlert(status, title: title, okAction: okAction)
        alertView.showSuccess(title, subTitle: status)
    }
    
    class func showErrorAlert(status: String, title:String) {
        self.showErrorAlert(status, title: title, okAction: {})
    }
    
    class func showErrorAlert(status: String, title: String, okAction:() -> Void) {
        let alertView = buildOKAlert(status, title: title, okAction: okAction)
        alertView.showError(title, subTitle: status)
    }
    
    class func showAPIErrorAlert(status: String, title:String, forceShow: (Bool?) = false) {
        self.showAPIErrorAlert(status, title: title, forceShow: forceShow, okAction: {})
    }
    
    class func showAPIErrorAlert(status: String, title:String, forceShow: (Bool?) = false, okAction:() -> Void) {
        let errorDate = NSDate()
        
        if forceShow != nil && forceShow! {
            self.showErrorAlert(status, title: title, okAction: okAction)
            lastErrorDate = errorDate
            return
        }
        
        if lastErrorDate != nil {
            let secondsPassed = errorDate.timeIntervalSinceDate(lastErrorDate!)
            if secondsPassed > 10 {
                self.showErrorAlert(status, title: title, okAction: okAction)
                lastErrorDate = errorDate
            }
        }
        else {
            self.showErrorAlert(status, title: title, okAction: okAction)
            lastErrorDate = errorDate
        }
    }
    
    class func showYesNoAlert(status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:() -> Void, noAction:() -> Void) {
        let alertView = buildYesNoAlert(status, title: title, yesTitle: yesTitle, noTitle: noTitle, yesAction: yesAction, noAction: noAction)
        alertView.showInfo(title, subTitle: status)
    }
    
    class func showYesNoSuccessAlert(status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:() -> Void, noAction:() -> Void) {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        
        alertView.addButton(yesTitle, action: yesAction)
        let closeBtn = alertView.addButton(noTitle, action: noAction)
        
        alertView.showSuccess(title, subTitle: status)
        
        let back = closeBtn.backgroundColor
        closeBtn.backgroundColor = UIColor.clearColor()
        closeBtn.layer.borderWidth = 1
        closeBtn.layer.borderColor = back?.CGColor
        closeBtn.setTitleColor(back, forState: .Normal)
    }
    
    class func showInputUsername(okTitle: String="Done", cancelTitle: String="Cancel", okAction:(username: String) -> Void, cancelAction:() -> Void) {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false

        let textField = alertView.addTextField()
        textField.placeholder = "Username"
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        
        alertView.addButton(okTitle, action: {
            let text = textField.text
            
            if text?.characters.count > 0 {
                okAction(username: text!)
            }
            else {
                self.showErrorAlert("Please enter a valid username.", title: App.Title, okAction: {
                    self.showInputUsername(okAction: okAction, cancelAction: cancelAction)
                })
            }
        })
        let closeBtn = alertView.addButton(cancelTitle, action: cancelAction)
        
        alertView.showInfo(App.Title, subTitle: "Choose a username for your account.")
        
        let back = closeBtn.backgroundColor
        closeBtn.backgroundColor = UIColor.clearColor()
        closeBtn.layer.borderWidth = 1
        closeBtn.layer.borderColor = back?.CGColor
        closeBtn.setTitleColor(back, forState: .Normal)
    }
    
    private class func buildOKAlert(status: String, title: String, okAction:() -> Void) -> SCLAlertView {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        
        alertView.addButton("OK", action: okAction)
        
        return alertView
    }
    
    private class func buildYesNoAlert(status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:() -> Void, noAction:() -> Void) -> SCLAlertView {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        
        alertView.addButton(yesTitle, action: yesAction)
        alertView.addButton(noTitle, action: noAction)
        
        return alertView
    }
}
