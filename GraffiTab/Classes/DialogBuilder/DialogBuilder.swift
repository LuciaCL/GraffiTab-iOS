//
//  DialogBuilder.swift
//  kv-app-tv
//
//  Created by Georgi Christov on 09/11/2015.
//  Copyright © 2015 Qumu Inc. All rights reserved.
//

import UIKit
import PopupDialog
import GraffiTab_iOS_SDK

class DialogBuilder: NSObject {

    static var lastErrorDate: NSDate?
    
    // MARK: - OK alerts
    
    class func showOKAlert(controller: UIViewController, status: String, title: String) {
        showOKAlert(controller, status: status, title: title, okAction: {})
    }
    
    class func showOKAlert(controller: UIViewController, status: String, title: String, okAction:() -> Void) {
        buildOKAlert(controller, status: status, title: title, okAction: okAction)
    }
    
    // MARK: - Success alerts
    
    class func showSuccessAlert(controller: UIViewController, status: String, title: String) {
        buildOKAlert(controller, status: status, title: title, okAction: {})
    }
    
    class func showSuccessAlert(controller: UIViewController, status: String, title: String, okAction:() -> Void) {
        buildOKAlert(controller, status: status, title: title, okAction: okAction)
    }
    
    // MARK: - Error alerts
    
    class func showErrorAlert(controller: UIViewController, status: String, title:String) {
        showErrorAlert(controller, status: status, title: title, okAction: {})
    }
    
    class func showErrorAlert(controller: UIViewController, status: String, title: String, okAction:() -> Void) {
        buildOKAlert(controller, status: status, title: title, okAction: okAction)
    }
    
    class func showAPIErrorAlert(controller: UIViewController, status: String, title:String, forceShow: (Bool?) = false, reason: GTReason) {
        self.showAPIErrorAlert(controller, status: status, title: title, forceShow: forceShow, okAction: {}, reason: reason)
    }
    
    class func showAPIErrorAlert(controller: UIViewController, status: String, title:String, forceShow: (Bool?) = false, okAction:() -> Void, reason: GTReason) {
        let errorDate = NSDate()
        
        // Define custom action to listen for logout events.
        let action = {
            if (reason == .USER_NOT_LOGGED_IN || reason == .USER_NOT_IN_EXPECTED_STATE) && GTMeManager.sharedInstance.isLoggedIn() {
                Utils.logoutUserAndShowLoginController(controller)
            }
            else {
                okAction()
            }
        }
        
        if forceShow != nil && forceShow! {
            self.showErrorAlert(controller, status: status, title: title, okAction: action)
            lastErrorDate = errorDate
            return
        }
        
        if lastErrorDate != nil {
            let secondsPassed = errorDate.timeIntervalSinceDate(lastErrorDate!)
            if secondsPassed > 30 {
                self.showErrorAlert(controller, status: status, title: title, okAction: action)
                lastErrorDate = errorDate
            }
        }
        else {
            self.showErrorAlert(controller, status: status, title: title, okAction: action)
            lastErrorDate = errorDate
        }
    }
    
    class func showYesNoAlert(controller: UIViewController, status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:() -> Void, noAction:() -> Void) {
        buildYesNoAlert(controller, status: status, title: title, yesTitle: yesTitle, noTitle: noTitle, yesAction: yesAction, noAction: noAction)
    }
    
    class func showInputUsername(controller: UIViewController, okTitle: String=NSLocalizedString("other_done", comment: ""), cancelTitle: String=NSLocalizedString("other_cancel", comment: ""), okAction:(username: String) -> Void, cancelAction:() -> Void) {
        let inputVC = InputUsernameViewController(nibName: "InputUsernameViewController", bundle: nil)
        let popup = PopupDialog(viewController: inputVC, transitionStyle: .ZoomIn, buttonAlignment: .Horizontal, gestureDismissal: true)
        
        let buttonOne = DefaultButton(title: NSLocalizedString("other_done", comment: "")) {
            let text = inputVC.usernameField.text
            
            if text?.characters.count > 0 {
                okAction(username: text!)
            }
            else {
                self.showErrorAlert(controller, status: NSLocalizedString("dialog_input_prompt", comment: ""), title: App.Title, okAction: {
                    self.showInputUsername(controller, okAction: okAction, cancelAction: cancelAction)
                })
            }
        }
        let buttonTwo = CancelButton(title: NSLocalizedString("other_cancel", comment: "")) {
            cancelAction()
        }
        popup.addButtons([buttonTwo, buttonOne])
        
        controller.presentViewController(popup, animated: true, completion: nil)
    }
    
    // MARK: - Builders
    
    private class func buildOKAlert(controller: UIViewController, status: String, title: String, okAction:() -> Void) {
        let popup = buildDialog(status, title: title)
        
        let buttonOne = DefaultButton(title: "OK") {
            okAction()
        }
        popup.addButtons([buttonOne])
        
        controller.presentViewController(popup, animated: true, completion: nil)
    }
    
    private class func buildYesNoAlert(controller: UIViewController, status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:() -> Void, noAction:() -> Void) {
        let popup = buildDialog(status, title: title)
        
        let buttonOne = DefaultButton(title: yesTitle) {
            yesAction()
        }
        let buttonTwo = CancelButton(title: noTitle) {
            noAction()
        }
        popup.addButtons([buttonTwo, buttonOne])
        
        controller.presentViewController(popup, animated: true, completion: nil)
    }
    
    private class func buildDialog(status: String, title: String) -> PopupDialog {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.titleFont = UIFont.boldSystemFontOfSize(17)
        
        let db = DefaultButton.appearance()
        db.titleColor = AppConfig.sharedInstance.theme?.primaryColor
        
        let popup = PopupDialog(title: title, message: status, image: nil, buttonAlignment: .Horizontal, transitionStyle: .ZoomIn, gestureDismissal: true)
        return popup
    }
}
