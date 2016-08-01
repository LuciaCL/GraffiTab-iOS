//
//  SignUpViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 06/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import GraffiTab_iOS_SDK
import CocoaLumberjack

class SignUpViewController: BackButtonTableViewController, UITextFieldDelegate {

    @IBOutlet weak var firstnameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastnameField: JVFloatLabeledTextField!
    @IBOutlet weak var emailField: JVFloatLabeledTextField!
    @IBOutlet weak var usernameField: JVFloatLabeledTextField!
    @IBOutlet weak var passwordField: JVFloatLabeledTextField!
    @IBOutlet weak var confirmPasswordField: JVFloatLabeledTextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
        setupTextFields()
        setupButtons()
        setupLabels()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
        
        if self.navigationController?.navigationBarHidden == false {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    @IBAction func onClickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickSignUp(sender: AnyObject) {
        DDLogDebug("[\(NSStringFromClass(self.dynamicType))] Attempting user signup")
        
        // Register analytics events.
        AnalyticsUtils.sendAppEvent("sign_up", label: nil)
        
        self.view.endEditing(true)
        
        let fn = firstnameField.text
        let ln = lastnameField.text
        let e = emailField.text
        let u = usernameField.text
        let p = passwordField.text
        let cp = confirmPasswordField.text
        
        if InputValidator.validateSignUp(fn!, lastName: ln!, email: e!, username: u!, password: p!, confirmPassword: cp!) {
            self.view.showActivityViewWithLabel("Processing")
            self.view.rn_activityView.dimBackground = false
            
            GTUserManager.register(fn!, lastName: ln!, email: e!, username: u!, password: p!, successBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showSuccessAlert("You have successfully registered! Please check your email to activate your account.", title: "Almost done!", okAction: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }, failureBlock: { (response) in
                self.view.hideActivityView()
                
                DialogBuilder.showAPIErrorAlert(response.error.localizedMessage(), title: App.Title, forceShow: true)
            })
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SEGUE_TERMS" {
            let vc = segue.destinationViewController as! WebViewController
            vc.title = "Terms of Use"
            vc.filePath = NSBundle.mainBundle().pathForResource("terms", ofType: "html")
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (textField == firstnameField) {
            lastnameField .becomeFirstResponder()
        }
        else if (textField == lastnameField) {
            emailField.becomeFirstResponder()
        }
        else if (textField == emailField) {
            usernameField.becomeFirstResponder()
        }
        else if (textField == usernameField) {
            passwordField.becomeFirstResponder()
        }
        else if (textField == passwordField) {
            confirmPasswordField.becomeFirstResponder()
        }
        
        return true
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }
        else if indexPath.row == 8 {
            return 90
        }
        
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
        
        let iv = UIImageView(image: UIImage(named: "grafitab_login.png"));
        iv.contentMode = .ScaleAspectFill;
        iv.clipsToBounds = true;
        self.tableView.backgroundView = iv;
    }
    
    func setupTextFields() {
        firstnameField.attributedPlaceholder = NSAttributedString(string:firstnameField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        lastnameField.attributedPlaceholder = NSAttributedString(string:lastnameField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        emailField.attributedPlaceholder = NSAttributedString(string:emailField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        usernameField.attributedPlaceholder = NSAttributedString(string:usernameField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        passwordField.attributedPlaceholder = NSAttributedString(string:passwordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string:confirmPasswordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.7)])
    }
    
    func setupLabels() {
        let title = termsLbl.text! as String
        let attString = NSMutableAttributedString(string: title)
        let range = (title as NSString).rangeOfString("Terms of Use")
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 99, green: 131, blue: 151, alpha: 1.0), range: range)
        termsLbl.attributedText = attString;
    }
    
    func setupButtons() {
        signupBtn.layer.cornerRadius = 3
    }
}
