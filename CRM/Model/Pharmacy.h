//
//  Pharmacy.h
//  CRM
//
//  Created by FirstMac on 27.01.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conference, Visit;

@interface Pharmacy : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * doctorName;
@property (nonatomic, retain) NSString * house;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * network;
@property (nonatomic, retain) NSNumber * pharmacyId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSSet *conferences;
@property (nonatomic, retain) NSSet *visits;
@end

@interface Pharmacy (CoreDataGeneratedAccessors)

- (void)addConferencesObject:(Conference *)value;
- (void)removeConferencesObject:(Conference *)value;
- (void)addConferences:(NSSet *)values;
- (void)removeConferences:(NSSet *)values;

- (void)addVisitsObject:(Visit *)value;
- (void)removeVisitsObject:(Visit *)value;
- (void)addVisits:(NSSet *)values;
- (void)removeVisits:(NSSet *)values;

@end
