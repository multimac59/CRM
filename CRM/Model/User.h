//
//  User.h
//  CRM
//
//  Created by Roman Bolshakov on 2014/03/07.
//  Copyright (c) 2014年 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pharmacy, Region, Visit;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * regionDate;
@property (nonatomic, retain) NSString * userDate;
@property (nonatomic, retain) NSString * pharmDate;
@property (nonatomic, retain) NSString * visitDate;
@property (nonatomic, retain) NSString * userRegionDate;
@property (nonatomic, retain) NSString * preparatDate;
@property (nonatomic, retain) NSString * preparatDoseDate;
@property (nonatomic, retain) NSSet *regions;
@property (nonatomic, retain) NSSet *targetablePharmacies;
@property (nonatomic, retain) NSSet *visits;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addRegionsObject:(Region *)value;
- (void)removeRegionsObject:(Region *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

- (void)addTargetablePharmaciesObject:(Pharmacy *)value;
- (void)removeTargetablePharmaciesObject:(Pharmacy *)value;
- (void)addTargetablePharmacies:(NSSet *)values;
- (void)removeTargetablePharmacies:(NSSet *)values;

- (void)addVisitsObject:(Visit *)value;
- (void)removeVisitsObject:(Visit *)value;
- (void)addVisits:(NSSet *)values;
- (void)removeVisits:(NSSet *)values;

@end
