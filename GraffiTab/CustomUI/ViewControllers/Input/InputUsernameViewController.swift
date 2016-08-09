//
//  InputUsernameViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 09/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

protocol InputUsernameDelegate {
    
    func didInputUsername(value: String)
}

class InputUsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var descriptionField: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    
    var delegate: InputUsernameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITextFIeldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
