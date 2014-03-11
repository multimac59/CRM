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

- (BOOL)isValid
{
    if ([self commerceVisitIsValid] || [self promoVisitIsValid] || [self pharmacyCirceIsValid])
        return YES;
    else
        return NO;
}

- (BOOL)promoVisitIsValid
{
    if (self.promoVisit)
    {
        if (self.promoVisit.brands.count > 0 || self.promoVisit.participants.integerValue > 0)
            return YES;
        else
            return NO;
    }
    else
    {
        return NO;
    }
}

- (BOOL)pharmacyCirceIsValid
{
    if (self.pharmacyCircle)
    {
        if (self.pharmacyCircle.brands.count > 0 || self.pharmacyCircle.participants.integerValue > 0)
            return YES;
        else
            return NO;
    }
    else
    {
        return NO;
    }
}

- (BOOL)commerceVisitIsValid
{
    if (self.commerceVisit)
    {
        for (Sale* sale in self.commerceVisit.sales)
        {
            if ([sale isValid])
                return YES;
        }
        return NO;
    }
    else
    {
        return NO;
    }
}

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
    if ([self promoVisitIsValid])
    {
        [dic setObject:[self.promoVisit encodeToJSON] forKey:@"promoVisit"];
    }
    if ([self pharmacyCirceIsValid])
    {
        [dic setObject:[self.pharmacyCircle encodeToJSON] forKey:@"pharmacyCircle"];
    }
    if ([self commerceVisitIsValid])
    {
        [dic setObject:[self.commerceVisit encodeToJSON] forKey:@"sales"];
    }
    return dic;
}
@end