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


@implementation Visit

@dynamic closed;
@dynamic date;
@dynamic visitId;
@dynamic commerceVisit;
@dynamic pharmacy;
@dynamic pharmacyCircle;
@dynamic promoVisit;
@dynamic user;

- (NSDictionary*)encodeToJSON
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:self.visitId forKey:@"id"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"RU-ru"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    [dic setObject:[dateFormatter stringFromDate:self.date] forKey:@"date"];
    if (self.promoVisit)
    {
        [dic setObject:[self.promoVisit encodeToJSON] forKey:@"promoVisit"];
    }
    if (self.pharmacyCircle)
    {
        [dic setObject:[self.pharmacyCircle encodeToJSON] forKey:@"pharmacyCircle"];
    }
    if (self.commerceVisit)
    {
        [dic setObject:[self.commerceVisit encodeToJSON] forKey:@"sales"];
    }
    return dic;
}
@end