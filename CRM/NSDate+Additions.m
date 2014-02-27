//
//  NSDate+Additions.m
//  CRM
//
//  Created by FirstMac on 26.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)
+ (NSDate*)currentDate
{
    NSDate* currentDate;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&currentDate interval:NULL forDate:[NSDate date]];
    return currentDate;
}
@end