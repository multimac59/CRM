//
//  Pharmacy+QuarterVisits.m
//  CRM
//
//  Created by FirstMac on 07.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "Pharmacy+QuarterVisits.h"
#import "NSDate+Additions.h"

@implementation Pharmacy (QuarterVisits)
- (NSArray*)visitsInCurrentQuarter
{
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentMonth = todayComponents.month;
    NSInteger quarter = currentMonth / 3 + 1;
    NSDateComponents* startComponents = [[NSDateComponents alloc]init];
    NSDateComponents* endComponents = [[NSDateComponents alloc]init];
    startComponents.month = (quarter - 1) * 3 + 1;
    endComponents.month = (quarter - 1) * 3 + 4;
    startComponents.day = endComponents.day = 1;
    startComponents.hour = endComponents.hour = 0;
    startComponents.minute = endComponents.minute = 0;
    startComponents.second = endComponents.second = 0;
    startComponents.year = endComponents.year = todayComponents.year;
    startComponents.year = endComponents.year - 10; //TODO: just for test, delete it later!
    NSDate* startDate = [[NSCalendar currentCalendar]dateFromComponents:startComponents];
    NSDate* endDate = [[NSCalendar currentCalendar]dateFromComponents:endComponents];
    
    if ([endDate compare:[NSDate currentDate]] == NSOrderedDescending)
    {
        endDate = [NSDate currentDate];
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date>=%@ && date < %@", startDate, endDate];
    NSArray* visitsForQuarter = [self.visits.allObjects filteredArrayUsingPredicate:predicate];
    return visitsForQuarter;
}
@end
