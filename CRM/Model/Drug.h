//
//  Drug.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dose;

@interface Drug : NSManagedObject

@property (nonatomic, retain) NSNumber * drugId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *doses;
@end

@interface Drug (CoreDataGeneratedAccessors)

- (void)addDosesObject:(Dose *)value;
- (void)removeDosesObject:(Dose *)value;
- (void)addDoses:(NSSet *)values;
- (void)removeDoses:(NSSet *)values;

@end
