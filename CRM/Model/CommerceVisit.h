//
//  CommerceVisit.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Sale, Visit;

@interface CommerceVisit : NSManagedObject

@property (nonatomic, retain) NSSet *sales;
@property (nonatomic, retain) Visit *visit;
@end

@interface CommerceVisit (CoreDataGeneratedAccessors)

- (void)addSalesObject:(Sale *)value;
- (void)removeSalesObject:(Sale *)value;
- (void)addSales:(NSSet *)values;
- (void)removeSales:(NSSet *)values;

@end
