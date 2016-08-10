//
//  main.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import Foundation
import UIKit

// Your initialization code here.

// Setup language.
NSUserDefaults.standardUserDefaults().setObject(NSArray(object: AppConfig.sharedInstance.languages[Settings.sharedInstance.language!]!), forKey: "AppleLanguages")
NSUserDefaults.standardUserDefaults().synchronize()

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(AppDelegate))
