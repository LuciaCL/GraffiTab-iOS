//
//  ViewController+ActionSheet.swift
//  GraffiTab
//
//  Created by Georgi Christov on 22/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import AHKActionSheet

extension UIViewController {
    
    func buildActionSheet(title: String?) -> AHKActionSheet {
        let actionSheet = AHKActionSheet(title: title)
        actionSheet.blurTintColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        actionSheet.blurRadius = 8.0
        actionSheet.buttonHeight = 50.0
        actionSheet.cancelButtonHeight = 50.0
        actionSheet.animationDuration = 0.5
        actionSheet.cancelButtonShadowColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        actionSheet.separatorColor = UIColor.clearColor()
        actionSheet.selectedBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        actionSheet.cancelButtonTitle = NSLocalizedString("other_cancel", comment: "")
        
        let defaultFont = UIFont.systemFontOfSize(17)
        actionSheet.buttonTextAttributes = [NSFontAttributeName:defaultFont,
                                            NSForegroundColorAttributeName:UIColor.whiteColor()];
        actionSheet.disabledButtonTextAttributes = [NSFontAttributeName:defaultFont,
                                                    NSForegroundColorAttributeName:UIColor.grayColor()];
        actionSheet.destructiveButtonTextAttributes = [NSFontAttributeName:defaultFont,
                                                       NSForegroundColorAttributeName:UIColor.redColor()];
        actionSheet.cancelButtonTextAttributes = [NSFontAttributeName:defaultFont,
                                                  NSForegroundColorAttributeName:UIColor.whiteColor()];
        
        return actionSheet
    }
    
    func showActionSheet(actionSheet: AHKActionSheet) {
        actionSheet.show()
        
        if DeviceType.IS_IPAD {
            for subview in actionSheet.subviews {
                if subview.isKindOfClass(UITableView.classForCoder()) {
                    let tableView = subview as? UITableView
                    for sv in tableView!.tableHeaderView!.subviews {
                        if sv.isKindOfClass(UILabel.classForCoder()) {
                            let label = sv as? UILabel
                            
                            var f = label?.frame
                            f?.origin.x = Orientation.isLandscape() ? 175 : 50
                            label?.frame = f!
                            return
                        }
                    }
                }
            }
        }
    }
}
