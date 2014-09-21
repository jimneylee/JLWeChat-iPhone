//
//  NSDate+IM.h
//  JLIM4iPhone
//
//  Created by jimneylee on 14-5-22.
//  Copyright (c) 2014年 jimneylee. All rights reserved.
//

#define WEEK_DAYS @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"]

@interface NSDate (IM)

// yyyy-MM-dd HH:mm:ss
+ (NSDate *)formatLongDateTimeFromString:(NSString *)string;

- (NSString *)formatRecentContactDate;

- (NSString *)formatChatMessageDate;

- (BOOL)isToday;

- (BOOL)isYesterday;

- (BOOL)isTomorrow;

- (BOOL)isInWeek;

@end
