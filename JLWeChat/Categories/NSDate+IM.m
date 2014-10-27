//
//  NSDate+IM.m
//  JLWeChat
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "NSDate+IM.h"

@implementation NSDate (IMCategory)

+ (NSDate *)formatLongDateTimeFromString:(NSString *)string
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }

    return [dateFormatter dateFromString:string];
}

- (NSString *)formatRecentContactDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                         NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                        NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday
                                                   fromDate:self];
    
    static NSDateFormatter *formatter = nil;
    NSString *dateString = nil;
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    if (todayComponents.day == dateComponents.day) {
        formatter.dateFormat = @"hh:mm";
        dateString = [formatter stringFromDate:self];
    }
    else if (todayComponents.day - 1 == dateComponents.day) {
        dateString = @"昨天";
    }
    else if (todayComponents.day - dateComponents.day <= 7) {
        if (WEEK_DAYS.count > dateComponents.weekday-1) {
            dateString = WEEK_DAYS[dateComponents.weekday-1];
        }
    }
    else {
        formatter.dateFormat = @"YY-MM-dd";
        dateString = [formatter stringFromDate:self];
    }
    
    return dateString;
}

- (NSString *)formatChatMessageDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                         NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                        NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday
                                                   fromDate:self];
    
    static NSDateFormatter *formatter = nil;
    NSString *dateString = nil;
    NSString *hourMinuteString = nil;

    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    formatter.dateFormat = @"hh:mm";
    hourMinuteString = [formatter stringFromDate:self];
    
    if (todayComponents.day == dateComponents.day) {
        dateString = hourMinuteString;
    }
    else if (todayComponents.day - 1 == dateComponents.day) {
        dateString = [NSString stringWithFormat:@"昨天 %@", hourMinuteString];
    }
    else if (todayComponents.day - dateComponents.day <= 7) {
        if (WEEK_DAYS.count > dateComponents.weekday-1) {
            dateString = [NSString stringWithFormat:@"%@ %@",
                          WEEK_DAYS[dateComponents.weekday-1], hourMinuteString];
        }
    }
    else {
        formatter.dateFormat = @"YY-MM-dd hh:mm";
        dateString = [formatter stringFromDate:self];
    }
    
    return dateString;
}

- (BOOL)isToday
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitDay
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:self];
    
    if (todayComponents.day == dateComponents.day) {
        return YES;
    }
    return NO;
}

- (BOOL)isYesterday
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitDay
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:self];
    
    if (todayComponents.day - 1 == dateComponents.day) {
        return YES;
    }
    return NO;
}

- (BOOL)isTomorrow
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitDay
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:self];
    
    if (todayComponents.day + 1 == dateComponents.day) {
        return YES;
    }
    return NO;
}

- (BOOL)isInWeek
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:NSCalendarUnitDay
                                                    fromDate:[NSDate date]];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay
                                                   fromDate:self];
    
    if (todayComponents.day - dateComponents.day <= 7) {
        return YES;
    }
    return NO;
}

@end
