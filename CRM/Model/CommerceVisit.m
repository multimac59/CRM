//
//  CommerceVisit.m
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "CommerceVisit.h"
#import "Sale.h"
#import "Visit.h"


@implementation CommerceVisit

@dynamic sales;
@dynamic visit;

- (NSArray*)encodeToJSON
{
    NSMutableArray* salesArr = [NSMutableArray new];
    [self.sales enumerateObjectsUsingBlock:^(Sale* sale, BOOL *stop) {
        if (sale.remainder.integerValue != 0 || sale.order.integerValue != 0 || sale.sold.integerValue != 0)
        {
            NSDictionary* saleDic = [sale encodeToJSON];
            [salesArr addObject:saleDic];
        }
    }];
    return salesArr;
}
@end
