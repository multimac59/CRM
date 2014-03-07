//
//  VisitPlanner.m
//  CRM
//
//  Created by FirstMac on 03.03.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "AppDelegate.h"
#import "VisitManager.h"
#import "Pharmacy.h"
#import "Visit.h"
#import "CommerceVisit.h"
#import "PromoVisit.h"
#import "PharmacyCircle.h"

@implementation VisitManager
+ (id)sharedManager {
    static VisitManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (Visit*)createVisitInPharamacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Visit"
                    inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
    visit.pharmacy = pharmacy;
    visit.date = date;
    visit.user = [AppDelegate sharedDelegate].currentUser;
    visit.visitId = [[NSUUID UUID]UUIDString];
    visit.closed = @NO;
    visit.sent = @NO;
    [pharmacy addVisitsObject:visit];
    return visit;
}

- (Visit*)visitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    for (Visit* visit in pharmacy.visits)
    {
        //get date without time component. We don't need it in fact, because we already have it without time from calendar control
        NSDate* startDate;
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&startDate interval:NULL forDate:date];
        //Add one day
        NSDateComponents *oneDay = [NSDateComponents new];
        oneDay.day = 1;
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay
                                                                        toDate:startDate
                                                                       options:0];
        if ([visit.date compare:startDate] != NSOrderedAscending && [visit.date compare:endDate] == NSOrderedAscending && visit.user.userId == [AppDelegate sharedDelegate].currentUser.userId)
        {
            return visit;
        }
    }
    return nil;
}

- (BOOL)toggleCommerceVisitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [self visitInPharmacy:pharmacy forDate:date];
    if (visit.closed.boolValue)
    {
        if (visit.commerceVisit)
            return YES;
        else
            return NO;
    }
    if (!visit)
    {
        Visit* visit = [self createVisitInPharamacy:pharmacy forDate:date];
        CommerceVisit* commerceVisit = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"CommerceVisit"
                                        inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        visit.commerceVisit = commerceVisit;
        //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        [[AppDelegate sharedDelegate]saveContext];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
        return YES;
    }
    else
    {
        if (visit.commerceVisit)
        {
            [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit.commerceVisit];
            visit.commerceVisit = nil;
            if (!visit.promoVisit && !visit.pharmacyCircle)
            {
                [pharmacy removeVisitsObject:visit];
                [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit];
            }
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Нет", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return NO;
        }
        else
        {
            CommerceVisit* commerceVisit = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"CommerceVisit"
                                            inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
            visit.commerceVisit = commerceVisit;
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return YES;
        }
    }
}

- (BOOL)togglePromoVisitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [self visitInPharmacy:pharmacy forDate:date];
    if (visit.closed.boolValue)
    {
        if (visit.promoVisit)
            return YES;
        else
            return NO;
    }
    if (!visit)
    {
        Visit* visit = [self createVisitInPharamacy:pharmacy forDate:date];
        PromoVisit* promoVisit = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"PromoVisit"
                                        inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        visit.promoVisit = promoVisit;
        //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        [[AppDelegate sharedDelegate]saveContext];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
        return YES;
    }
    else
    {
        if (visit.promoVisit)
        {
            [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit.promoVisit];
            visit.promoVisit = nil;
            if (!visit.commerceVisit && !visit.pharmacyCircle)
            {
                [pharmacy removeVisitsObject:visit];
                [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit];
            }
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Нет", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return NO;
        }
        else
        {
            PromoVisit* promoVisit = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"PromoVisit"
                                            inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
            visit.promoVisit = promoVisit;
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return YES;
        }
    }
}

- (BOOL)togglePharmacyCircleInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date
{
    Visit* visit = [self visitInPharmacy:pharmacy forDate:date];
    if (visit.closed.boolValue)
    {
        if (visit.pharmacyCircle)
            return YES;
        else
            return NO;
    }
    if (!visit)
    {
        Visit* visit = [self createVisitInPharamacy:pharmacy forDate:date];
        PharmacyCircle* pharmacyCircle = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"PharmacyCircle"
                                  inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
        visit.pharmacyCircle = pharmacyCircle;
        //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
        [[AppDelegate sharedDelegate]saveContext];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
        return YES;
    }
    else
    {
        if (visit.pharmacyCircle)
        {
            [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit.pharmacyCircle];
            visit.pharmacyCircle = nil;
            if (!visit.commerceVisit && !visit.promoVisit)
            {
                [pharmacy removeVisitsObject:visit];
                [[AppDelegate sharedDelegate].managedObjectContext deleteObject:visit];
            }
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Нет", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return NO;
        }
        else
        {
            PharmacyCircle* pharmacyCircle = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"PharmacyCircle"
                                      inManagedObjectContext:[AppDelegate sharedDelegate].managedObjectContext];
            visit.pharmacyCircle = pharmacyCircle;
            //[Flurry logEvent:@"Планирование" withParameters:@{@"Событие" : @"Продажи", @"Состояние" : @"Да", @"Аптека" : visit.pharmacy.name, @"Дата визита" : self.selectedDate, @"Пользователь" : [AppDelegate sharedDelegate].currentUser.login, @"Дата" : [NSDate date]}];
            [[AppDelegate sharedDelegate]saveContext];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"VisitsUpdated" object:self];
            return YES;
        }
    }
}
@end