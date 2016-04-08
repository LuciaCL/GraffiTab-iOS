//
//  DateUtils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 08/04/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

class DateUtils: NSObject {

    class func timePassedSinceDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date, toDate: NSDate(), options: [])
        
        var date = "";
        if components.year > 0 {
            date = String(format: "%liy", components.year)
        }
        else if components.month > 0 {
            date = String(format: "%limo", components.month)
        }
        else if components.day > 0 {
            date = String(format: "%lid", components.day)
        }
        else if components.hour > 0 {
            date = String(format: "%lih", components.hour)
        }
        else if components.minute > 0 {
            date = String(format: "%lim", components.minute)
        }
        else if components.second > 0 {
            date = String(format: "%lis", components.second)
        }
        else {
            date = "now"
        }
        
        return date
    }
}
