//
//  EditTextFieldViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class EditTextFieldViewController: BackButtonTableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    var defaultValue: String?
    var allowEmpty: Bool?
    var doneBlock: ((value: String) -> Void)?
    var capitalizationType: UITextAutocapitalizationType = .None
    var keyboardType: UIKeyboardType = .Default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTextFields()
        
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickDone() {
        if !allowEmpty! && textField.text?.characters.count <= 0 {
            DialogBuilder.showErrorAlert("This field cannot be empty.", title: App.Title)
            return
        }
        
        doneBlock!(value: textField.text!)
        
        self.navigationController?.popViewControllerAnimated(true)
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
        
        self.title = "Edit"
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle("Done", forState: .Normal)
        button.backgroundColor = UIColor(hexString: Colors.Orange)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditTextFieldViewController.onClickDone), forControlEvents: .TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
    
    func setupTextFields() {
        textField.autocapitalizationType = capitalizationType
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .No
    }
}
