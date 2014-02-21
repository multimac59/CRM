//
//  Dose.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drug, Sale;

@interface Dose : NSManagedObject

@property (nonatomic, retain) NSNumber * doseId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) Drug *drug;
@property (nonatomic, retain) NSSet *sales;
@end

@interface Dose (CoreDataGeneratedAccessors)

- (void)addSalesObject:(Sale *)value;
- (void)removeSalesObject:(Sale *)value;
- (void)addSales:(NSSet *)values;
- (void)removeSales:(NSSet *)values;

@end
