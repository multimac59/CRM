//
//  Pharmacy.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Region, User, Visit;

@interface Pharmacy : NSManagedObject

typedef enum {
    NormalStatus,
    BronzeStatus,
    SilverStatus,
    GoldStatus
} PharmacyStatus;

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * doctorName;
@property (nonatomic, retain) NSString * house;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sales;
@property (nonatomic, retain) NSNumber * network;
@property (nonatomic, retain) NSNumber * pharmacyId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * psp;
@property (nonatomic) PharmacyStatus status;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSSet *visits;
@end

@interface Pharmacy (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

- (void)addVisitsObject:(Visit *)value;
- (void)removeVisitsObject:(Visit *)value;
- (void)addVisits:(NSSet *)values;
- (void)removeVisits:(NSSet *)values;

@end
