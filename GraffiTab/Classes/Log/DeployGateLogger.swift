//
//  DeployGateLogger.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/06/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit
import CocoaLumberjack

class DeployGateLogger: DDAbstractLogger {

    static let sharedInstance = DeployGateLogger()
    
    private var _logFormatter : DDLogFormatter?
    override var logFormatter: DDLogFormatter? {
        get {
            return _logFormatter
        }
        set {
            _logFormatter = newValue
        }
    }
    
    override func logMessage(logMessage: DDLogMessage!) {
        var logMsg = logMessage.message
        
        if (logFormatter != nil) {
            logMsg = logFormatter!.formatLogMessage(logMessage)
        }
        
        if logMsg != nil {
            DebugLog(logMsg)
        }
    }
    
    func DebugLog(message: String,
                  file: StaticString = #file,
                  function: StaticString = #function,
                  line: Int = #line)
    {
//        let output: String
//        if let filename = NSURL(string:file.stringValue)?.lastPathComponent?.componentsSeparatedByString(".").first
//        {
//            output = "\(filename).\(function) line \(line) $ \(message)"
//        }
//        else
//        {
//            output = "\(file).\(function) line \(line) $ \(message)"
//        }
        
        #if DEBUG
            
        #else
            DGSLogv("%@", getVaList([message]))
        #endif
    }
}
