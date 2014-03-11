//
//  Visit.m
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "Visit.h"
#import "CommerceVisit.h"
#import "Pharmacy.h"
#import "PharmacyCircle.h"
#import "PromoVisit.h"
#import "User.h"
#import "Sale.h"


@implementation Visit

@dynamic closed;
@dynamic date;
@dynamic visitId;
@dynamic commerceVisit;
@dynamic pharmacy;
@dynamic pharmacyCircle;
@dynamic promoVisit;
@dynamic user;
@dynamic sent;
@dynamic serverId;

- (NSDictionary*)encodeToJSON
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:self.visitId forKey:@"id"];
    //Pharmacy* pharmacy = self.pharmacy;
    [dic setObject:self.pharmacy.pharmacyId forKey:@"pharm_id"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"RU-ru"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    [dic setObject:[dateFormatter stringFromDate:self.date] forKey:@"date"];
    if (self.promoVisit && (self.promoVisit.brands.count > 0 || self.promoVisit.participants > 0))
    {
        [dic setObject:[self.promoVisit encodeToJSON] forKey:@"promoVisit"];
    }
    if (self.pharmacyCircle  && (self.promoVisit.brands.count > 0 || self.promoVisit.participants > 0))
    {
        [dic setObject:[self.pharmacyCircle encodeToJSON] forKey:@"pharmacyCircle"];
    }
    if (self.commerceVisit)
    {
        BOOL salesExist = NO;
        for (Sale* sale in self.commerceVisit.sales)
        {
            if (sale.remainder.integerValue != 0 || sale.order.integerValue != 0 || sale.sold.integerValue != 0 || sale.comment != nil)
            {
                salesExist = YES;
                break;
            }
        }
        if (salesExist)
            [dic setObject:[self.commerceVisit encodeToJSON] forKey:@"sales"];
    }
    return dic;
}
@end