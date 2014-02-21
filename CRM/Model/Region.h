//
//  Region.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pharmacy, User;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * regionId;
@property (nonatomic, retain) NSSet *pharmacies;
@property (nonatomic, retain) NSSet *users;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPharmaciesObject:(Pharmacy *)value;
- (void)removePharmaciesObject:(Pharmacy *)value;
- (void)addPharmacies:(NSSet *)values;
- (void)removePharmacies:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
