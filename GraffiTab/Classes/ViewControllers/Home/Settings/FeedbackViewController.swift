//
//  FeedbackViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 12/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import GraffiTab_iOS_SDK
import CocoaLumberjack

class FeedbackViewController: BackButtonTableViewController {

    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func onClickSend() {
        if textField.text.characters.count > 0 {
            DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting to send feedback")
            
            // Register analytics events.
            AnalyticsUtils.sendAppEvent("feedback", label: nil)
            
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            let user = GTSettings.sharedInstance.user
            GTFeedbackManager.sendFeedback(user!.getFullName(), email: user!.email!, text: textField.text, successBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert("Thanks for your feedback!", title: App.Title, okAction: { 
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }) { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.message, title: App.Title, forceShow: true)
            }
        }
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = "Feedback"
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle("Send", forState: .Normal)
        button.backgroundColor = UIColor(hexString: Colors.Orange)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(FeedbackViewController.onClickSend), forControlEvents: .TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
}
