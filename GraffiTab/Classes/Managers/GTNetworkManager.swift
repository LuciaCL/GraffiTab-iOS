//
//  GTNetworkManager.swift
//  GraffiTab
//
//  Created by Georgi Christov on 28/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import Reachability
import CocoaLumberjack

class GTNetworkManager: NSObject {

    static var manager: GTNetworkManager = GTNetworkManager()
    
    var noNetworkLabel: UILabel?
    var window: UIWindow?
    
    let reach = Reachability(hostName: "www.google.com")
    let height = CGFloat(27)
    var animating = false
    
    override init() {
        super.init()
        
        window = (UIApplication.sharedApplication().delegate as! AppDelegate).window
        
        setupLabels()
        setupReachability()
    }
    
    func showNetwork() {
        if animating {
            return
        }
        
        noNetworkLabel?.text = NSLocalizedString("manager_network_connected", comment: "")
        noNetworkLabel?.backgroundColor = UIColor(hexString: Colors.Green)!
        noNetworkLabel?.setNeedsDisplay()
        animateLabel()
    }
    
    func showNoNetwork() {
        if animating {
            return
        }
        
        noNetworkLabel?.text = NSLocalizedString("manager_network_not_connected", comment: "")
        noNetworkLabel?.backgroundColor = UIColor.blackColor()
        noNetworkLabel?.setNeedsDisplay()
        animateLabel()
    }
    
    func animateLabel() {
        self.animating = true
        self.window?.bringSubviewToFront(self.noNetworkLabel!)
        
        UIView.animateWithDuration(0.3, animations: {
            var f = self.noNetworkLabel?.frame
            f!.origin.y = self.window!.bounds.height - self.height
            self.noNetworkLabel?.frame = f!
        }) { (finished) in
            if finished {
                Utils.runWithDelay(4, block: {
                    UIView.animateWithDuration(0.3, animations: {
                        var f = self.noNetworkLabel?.frame
                        f!.origin.y = self.window!.bounds.height
                        self.noNetworkLabel?.frame = f!
                    }) { (finished) in
                        self.animating = false
                    }
                })
            }
        }
    }
    
    // MARK: - Setup
    
    func setupReachability() {
        // Set the blocks.
        reach.reachableBlock = { (reachability) in
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application has connectivity")
            
            // keep in mind this is called on a background thread
            // and if you are updating the UI it needs to happen
            // on the main thread, like this:
            
            dispatch_async(dispatch_get_main_queue(), {
//                self.showNetwork()
            });
        }
        reach.unreachableBlock = { (reachability) in
            DDLogInfo("[\(NSStringFromClass(self.dynamicType))] Application lost connectivity")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.showNoNetwork()
            });
        }
        
        // Start the notifier, which will cause the reachability object to retain itself!
        reach.startNotifier()
    }
    
    func setupLabels() {
        // Setup info label.
        self.noNetworkLabel = UILabel(frame: CGRectMake(0, window!.bounds.height, window!.bounds.width, height))
        self.noNetworkLabel?.textColor = .whiteColor()
        self.noNetworkLabel?.textAlignment = .Center
        self.noNetworkLabel?.font = UIFont.systemFontOfSize(13)
        self.noNetworkLabel?.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleTopMargin]
        window?.addSubview(self.noNetworkLabel!)
    }
}
