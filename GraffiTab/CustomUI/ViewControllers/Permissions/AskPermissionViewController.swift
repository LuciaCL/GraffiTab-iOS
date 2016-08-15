//
//  AskPermissionViewController.swift
//  GraffiTab
//
//  Created by Georgi Christov on 03/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class AskPermissionViewController: UIViewController {

    @IBOutlet weak var permissionTitle: UILabel!
    @IBOutlet weak var permissionPreview: UIImageView!
    @IBOutlet weak var permissionDescription: UILabel!
    @IBOutlet weak var askBtn: UIButton!
    @IBOutlet weak var laterBtn: UIButton!
    
    var askPermissionHandler: (() -> Void)?
    var decideLaterHandler: (() -> Void)?
    
    class func showPermissionViewController(controller: UIViewController, askPermissionHandler: () -> Void, decideLaterHandler: () -> Void) -> AskPermissionViewController {
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        MZFormSheetPresentationController.appearance().shouldCenterHorizontally = true
        MZFormSheetPresentationController.appearance().shouldCenterVertically = true
        MZFormSheetPresentationController.appearance().shouldDismissOnBackgroundViewTap = false
        
        let vc = AskPermissionViewController(nibName: "AskPermissionViewController", bundle: nil)
        vc.askPermissionHandler = {
            vc.dismissViewControllerAnimated(true, completion: {
                askPermissionHandler()
            })
        }
        vc.decideLaterHandler = {
            vc.dismissViewControllerAnimated(true, completion: { 
                decideLaterHandler()
            })
        }
        
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: vc)
        formSheetController.presentationController?.contentViewSize = CGSizeMake(300, 450)
        formSheetController.contentViewControllerTransitionStyle = .SlideFromBottom
        
        controller.presentViewController(formSheetController, animated: true, completion: nil)
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
    }
    
    @IBAction func onClickAsk(sender: AnyObject) {
        if askPermissionHandler != nil {
            self.askPermissionHandler!()
        }
    }
    
    @IBAction func onClickDecideLater(sender: AnyObject) {
        if decideLaterHandler != nil {
            self.decideLaterHandler!()
        }
    }
    
    // MARK: - Setup
    
    func setupButtons() {
        askBtn.layer.cornerRadius = 3
        laterBtn.layer.borderWidth = 1
        laterBtn.layer.borderColor = askBtn.backgroundColor?.CGColor
        laterBtn.layer.cornerRadius = 3
        
        laterBtn.setTitle(NSLocalizedString("manager_permission_later_button", comment: ""), forState: .Normal)
    }
}
