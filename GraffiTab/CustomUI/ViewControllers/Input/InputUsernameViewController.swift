//
//  InputUsernameViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 09/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

protocol InputUsernameDelegate: class {
    
    func didInputUsername(value: String)
}

class InputUsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    
    weak var delegate: InputUsernameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTextViews()
    }
    
    // MARK: - UITextFIeldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Setup
    
    func setupTextViews() {
        titleField.text = NSLocalizedString("controller_input_username_title", comment: "")
        descriptionField.text = NSLocalizedString("controller_input_username_prompt", comment: "")
        
        usernameField.placeholder = NSLocalizedString("controller_login_username", comment: "")
        usernameField.textColor = AppConfig.sharedInstance.theme?.primaryColor
        usernameField.tintColor = AppConfig.sharedInstance.theme?.primaryColor
    }
}
