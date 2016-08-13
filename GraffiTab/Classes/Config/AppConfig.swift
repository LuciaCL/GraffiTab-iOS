//
//  AppConfig.swift
//  GraffiTab
//
//  Created by Georgi Christov on 10/08/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class AppConfig: NSObject {

    static var sharedInstance: AppConfig = AppConfig()
    
    var fallbackLanguage = "English"
    var languages = [
        "English" : "en_EN",
        "Español" : "es_ES"
//        "Български" : "bg_BG",
    ]
}
