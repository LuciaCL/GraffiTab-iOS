//
//  AnalyticsUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 27/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AnalyticsUtils: NSObject {

    static func sendScreenEvent(controller: UIViewController) {
        if AppConfig.sharedInstance.useAnalytics {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: NSStringFromClass(controller.dynamicType))
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }
    
    static func sendAppEvent(action: String, label: String?) {
        if AppConfig.sharedInstance.useAnalytics {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: action, label: label, value: nil).build() as [NSObject : AnyObject])
        }
    }
    
    static func sendCrashReport(exception: NSException, fatal: Bool) {
        if AppConfig.sharedInstance.useAnalytics {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.send(GAIDictionaryBuilder.createExceptionWithDescription(exception.description, withFatal: fatal).build() as [NSObject : AnyObject])
        }
    }
}
