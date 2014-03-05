//
//  PromoVisit.m
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "PromoVisit.h"
#import "Drug.h"
#import "Visit.h"


@implementation PromoVisit

@dynamic brands;
@dynamic participants;
@dynamic visit;

- (NSDictionary*)encodeToJSON
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:self.participants forKey:@"participants"];
    NSMutableArray* brandsArray = [NSMutableArray new];
    for (Drug* drug in self.brands)
    {
        [brandsArray addObject:drug.drugId];
    }
    [dic setObject:brandsArray forKey:@"brands"];
    return dic;
}

@end
