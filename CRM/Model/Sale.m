//
//  Sale.m
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "Sale.h"
#import "CommerceVisit.h"
#import "Dose.h"


@implementation Sale

@dynamic comment;
@dynamic order;
@dynamic remainder;
@dynamic sold;
@dynamic commerceVisit;
@dynamic dose;

- (NSDictionary*)encodeToJSON
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:self.order forKey:@"purchase"];
    [dic setObject:self.sold forKey:@"sold"];
    if (self.comment)
        [dic setObject:self.comment forKey:@"comment"];
    
    NSMutableDictionary* remainderDict = [NSMutableDictionary new];
    if (self.remainder.integerValue == -1)
    {
        [remainderDict setObject:@YES forKey:@"indeterminate"];
    }
    else
    {
        [remainderDict setObject:@NO forKey:@"indeterminate"];
        [remainderDict setObject:self.remainder forKey:@"value"];
    }
    
    [dic setObject:remainderDict forKey:@"remainder"];
    [dic setObject:self.dose.doseId forKey:@"doseId"];
    return dic;
}

- (BOOL)isValid
{
    if (self.remainder.integerValue != 0 || self.order.integerValue != 0 || self.sold.integerValue != 0 || self.comment != nil)
    {
        return YES;
    }
    else
        return NO;
}

@end