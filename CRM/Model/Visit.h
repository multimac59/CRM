//
//  Visit.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pharmacy, Sale, User;

@interface Visit : NSManagedObject

@property (nonatomic, retain) NSNumber * visitId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) NSSet *sales;
@end

@interface Visit (CoreDataGeneratedAccessors)

- (void)addSalesObject:(Sale *)value;
- (void)removeSalesObject:(Sale *)value;
- (void)addSales:(NSSet *)values;
- (void)removeSales:(NSSet *)values;

@end
