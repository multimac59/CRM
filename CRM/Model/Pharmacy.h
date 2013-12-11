//
//  Pharmacy.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pharmacy : NSManagedObject

@property (nonatomic, retain) NSNumber * pharmacyId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * network;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * house;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * doctorName;
@property (nonatomic, retain) NSSet *visits;
@end

@interface Pharmacy (CoreDataGeneratedAccessors)

- (void)addVisitsObject:(NSManagedObject *)value;
- (void)removeVisitsObject:(NSManagedObject *)value;
- (void)addVisits:(NSSet *)values;
- (void)removeVisits:(NSSet *)values;

@end
