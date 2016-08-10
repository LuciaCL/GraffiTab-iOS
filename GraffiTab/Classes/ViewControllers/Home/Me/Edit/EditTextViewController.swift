//
//  EditTextViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 13/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class EditTextViewController: BackButtonTableViewController {

    @IBOutlet weak var textView: UITextView!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register analytics events.
        AnalyticsUtils.sendScreenEvent(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    func onClickDone() {
        if !allowEmpty! && textView.text?.characters.count <= 0 {
            DialogBuilder.showErrorAlert(self, status: NSLocalizedString("controller_edit_text_mandatory", comment: ""), title: App.Title)
            return
        }
        
        doneBlock!(value: textView.text!)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Loading
    
    func loadData() {
        textView.text = defaultValue
    }
    
    // MARK: - Setup
    
    override func setupTopBar() {
        super.setupTopBar()
        
        self.title = NSLocalizedString("other_edit", comment: "")
        
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 50, 30)
        button.layer.cornerRadius = 3
        button.setTitle(NSLocalizedString("other_done", comment: ""), forState: .Normal)
        button.backgroundColor = UIColor(hexString: Colors.Orange)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        button.addTarget(self, action: #selector(EditTextFieldViewController.onClickDone), forControlEvents: .TouchUpInside)
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10
        
        self.navigationItem.rightBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: button)]
    }
    
    func setupTextFields() {
        textView.autocapitalizationType = capitalizationType
        textView.keyboardType = keyboardType
        textView.autocorrectionType = .No
    }
}
