//
//  DateUtils.m
//  GraffiTab-iOS
//
//  Created by Georgi Christov on 10/12/2014.
//  Copyright (c) 2014 GraffiTab. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSString *)timePassedSinceDate:(NSDate *)d {
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDateComponents *components = [c components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:d toDate:[NSDate date] options:0];
    
    NSString *date = @"";
    if (components.year > 0)
        date = [NSString stringWithFormat:@"%liy", components.year];
    else if (components.month > 0)
        date = [NSString stringWithFormat:@"%limo", components.month];
    else if (components.day > 0)
        date = [NSString stringWithFormat:@"%lid", components.day];
    else if (components.hour > 0)
        date = [NSString stringWithFormat:@"%lih", components.hour];
    else if (components.minute > 0)
        date = [NSString stringWithFormat:@"%lim", components.minute];
    else if (components.second > 0)
        date = [NSString stringWithFormat:@"%lis", components.second];
    else
        date = @"now";
    
    return date;
}

@end
