//
//  EditTextFieldViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class EditTextFieldViewController: BackButtonTableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    var defaultValue: String?
    var allowEmpty: Bool?
    var doneBlock: ((value: String) -> Void)?
    var capitalizationType: UITextAutocapitalizationType = .None
    var keyboardType: UIKeyboardType = .Default
    
    class func showEditFieldController(controller: UIViewController, doneBlock: ((value: String) -> Void), defaultValue: String, allowEmpty: Bool, capitalizationType: UITextAutocapitalizationType, keyboardType: UIKeyboardType) {
        let vc = controller.storyboard?.instantiateViewControllerWithIdentifier("EditTextFieldViewController") as! EditTextFieldViewController
        vc.keyboardType = keyboardType
        vc.allowEmpty = allowEmpty
        vc.defaultValue = defaultValue
        vc.doneBlock = doneBlock
        vc.capitalizationType = capitalizationType
        
        if DeviceType.IS_IPAD {
            MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = !DeviceType.IS_IPAD
            MZFormSheetPresentationController.appearance().shouldCenterHorizontally = true
            MZFormSheetPresentationController.appearance().shouldCenterVertically = true
            MZFormSheetPresentationController.appearance().shouldDismissOnBackgroundViewTap = true
            
            let formSheetController = MZFormSheetPresentationViewController(contentViewController: UINavigationController(rootViewController: vc))
            formSheetController.presentationController?.contentViewSize = CGSizeMake(450, 500)
            formSheetController.contentViewControllerTransitionStyle = .SlideFromBottom
            
            controller.presentViewController(formSheetController, animated: true, completion: nil)
        }
        else {
            controller.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTextFields()
        
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }

    func onClickDone() {
        if !allowEmpty! && textField.text?.characters.count <= 0 {
            DialogBuilder.showErrorAlert(self, status: NSLocalizedString("controller_edit_text_mandatory", comment: ""), title: App.Title)
            return
        }
        
        doneBlock!(value: textField.text!)
        
        if DeviceType.IS_IPAD {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func onClickClose() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Loading
    
    func loadData() {
        textField.text = defaultValue
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        onClickDone()
        
        return true
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("other_edit", comment: "")
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle(NSLocalizedString("other_done", comment: ""), forState: .Normal)
        button.backgroundColor = AppConfig.sharedInstance.theme!.primaryColor
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditTextFieldViewController.onClickDone), forControlEvents: .TouchUpInside)
        button.sizeToFit()
        button.frame = CGRectMake(0, 0, button.frame.width + 10, 30)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
        
        if DeviceType.IS_IPAD {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("other_close", comment: ""), style: .Plain, target: self, action: #selector(self.onClickClose))
        }
    }
    
    func setupTextFields() {
        textField.autocapitalizationType = capitalizationType
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .No
    }
}
