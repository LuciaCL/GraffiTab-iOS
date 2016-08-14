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
            date = String(format: NSLocalizedString("date_y", comment: ""), components.year)
        }
        else if components.month > 0 {
            date = String(format: NSLocalizedString("date_mo", comment: ""), components.month)
        }
        else if components.day > 0 {
            date = String(format: NSLocalizedString("date_d", comment: ""), components.day)
        }
        else if components.hour > 0 {
            date = String(format: NSLocalizedString("date_h", comment: ""), components.hour)
        }
        else if components.minute > 0 {
            date = String(format: NSLocalizedString("date_m", comment: ""), components.minute)
        }
        else if components.second > 0 {
            date = String(format: NSLocalizedString("date_s", comment: ""), components.second)
        }
        else {
            date = NSLocalizedString("date_now", comment: "")
        }
        
        return date
    }
    
    class func notificationTimePassedSinceDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date, toDate: NSDate(), options: [])
        
        var date = "";
        if components.year > 0 {
            date = String(format: NSLocalizedString("date_time_ago", comment: ""), components.year, components.year != 1 ? NSLocalizedString("date_years", comment: "") : NSLocalizedString("date_year", comment: ""))
        }
        else if components.month > 0 {
            date = String(format: NSLocalizedString("date_time_ago", comment: ""), components.month, components.month != 1 ? NSLocalizedString("date_months", comment: "") : NSLocalizedString("date_month", comment: ""))
        }
        else if components.day > 0 {
            date = String(format: NSLocalizedString("date_time_ago", comment: ""), components.day, components.day != 1 ? NSLocalizedString("date_days", comment: "") : NSLocalizedString("date_day", comment: ""))
        }
        else if components.hour > 0 {
            date = String(format: NSLocalizedString("date_time_ago", comment: ""), components.hour, components.hour != 1 ? NSLocalizedString("date_hours", comment: "") : NSLocalizedString("date_hour", comment: ""))
        }
        else if components.minute > 0 {
            date = String(format: NSLocalizedString("date_time_ago", comment: ""), components.minute, components.minute != 1 ? NSLocalizedString("date_minutes", comment: "") : NSLocalizedString("date_minute", comment: ""))
        }
        else {
            date = NSLocalizedString("date_just_now", comment: "")
        }
        
        return date
    }
}
