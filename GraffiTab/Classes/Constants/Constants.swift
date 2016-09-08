//
//  Constants.swift
//  kv-app-tv
//
//  Created by Georgi Christov on 12/11/2015.
//  Copyright © 2015 Qumu Inc. All rights reserved.
//

struct Notifications {
    static let UserLoggedIn = "UserLoggedIn"
    static let UserLoggedOut = "UserLoggedOut"
    static let AppStatusBarTouched = "AppStatusBarTouched"
}

struct App {
    static let Title = "GraffiTab"
    static let ColorsPerRow = 4
    static let Radius = 1000.0
}

struct Image {
    static let MaxImageWidth = 1024.0
}

struct BrandColors {
//    static let Primary = UIColor(hexString: "#005c86", alpha: 0.9)
    static let Primary = UIColor(hexString: "#2584b2")
    static let Secondary = UIColor(hexString: "#e9a13a")
    static let Metadata = UIColor(hexString: "#a0a0a0")
    
    static let collectionBackground = UIColor(hexString: "#F2F3F4")
    
    static let Links = Primary
    static let Mentions = Primary
    static let Hashtags = Primary
}

struct SettingsKeys {
    static let kUsername = "kUsername"
    static let kPassword = "kPassword"
    static let kAppDomain = "kAppDomain"
    
    static let kFirstStartDate = "kFirstStartDate"
    static let kAppLanguage = "kAppLanguage"
    static let kRememberCredentials = "kRememberCredentials"
    static let kDrawingAssistant = "kDrawingAssistant"
    static let kOnboarding = "kOnboarding"
    static let kFeedbackOnboarding = "kFeedbackOnboarding"
    
    static let kPromptedForAvatar = "kPromptedForAvatar"
    static let kPromptedForNotifications = "kPromptedForNotifications"
    static let kPromptedForPhotos = "kPromptedForPhotos"
    static let kPromptedForLocationInUse = "kPromptedForLocationInUse"
    static let kPromptedForLocationAlways = "kPromptedForLocationAlways"
    
    static let kAcceptedNotifications = "kAcceptedNotifications"
}

struct ScreenSize {
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD = UIDevice.currentDevice().userInterfaceIdiom == .Pad
}

struct Orientation {
    static func isLandscape() -> Bool {
        return UIApplication.sharedApplication().statusBarOrientation.isLandscape
    }
}

let colorPallete = ["cad0cc", "cdc7b9", "a9b3b2", "b9bbb8", "c2d1cc", "c2c8c4", "b4bfb9"]