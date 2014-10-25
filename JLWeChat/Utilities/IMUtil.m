//
//  IMUtil.m
//  JLWeChat
//
//  Created by jimneylee on 14-10-25.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#import "IMUtil.h"

@implementation IMUtil

+ (NSString *)generateImageTimeKey
{
    NSString *timeString = [IMUtil generateTimeKey];
    return [NSString stringWithFormat:@"%@.jpg", timeString];
}

+ (NSString *)generateVoiceTimeKey
{
    NSString *timeString = [IMUtil generateTimeKey];
    return [NSString stringWithFormat:@"%@.voice", timeString];
}

+ (NSString *)generateTimeKey
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    [f setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *timeString = [f stringFromDate:[NSDate date]];
    return timeString;
}

@end
