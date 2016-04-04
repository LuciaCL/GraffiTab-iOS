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

    class func showOKAlert(status: String, title:String) {
        SCLAlertView().showInfo(title, subTitle: status, closeButtonTitle: "OK")
    }
    
    class func showSuccessAlert(status: String, title:String) {
        SCLAlertView().showSuccess(title, subTitle: status, closeButtonTitle: "OK")
    }
    
    class func showErrorAlert(status: String, title:String) {
        SCLAlertView().showError(title, subTitle: status, closeButtonTitle: "OK")
    }
    
    class func showYesNoAlert(status: String, title: String, yesTitle: String="Yes", noTitle: String="No", yesAction:()->Void, noAction:()->Void) {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        
        alertView.addButton(yesTitle, action: yesAction)
        alertView.addButton(noTitle, action: noAction)
        
        alertView.showInfo(title, subTitle: status)
    }
}
