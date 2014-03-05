//
//  PromoVisit.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drug, Participant, Visit;

@interface PromoVisit : NSManagedObject

@property (nonatomic, retain) NSSet *brands;
@property (nonatomic, retain) NSNumber *participants;
@property (nonatomic, retain) Visit *visit;
@end

@interface PromoVisit (CoreDataGeneratedAccessors)

- (void)addBrandsObject:(Drug *)value;
- (void)removeBrandsObject:(Drug *)value;
- (void)addBrands:(NSSet *)values;
- (void)removeBrands:(NSSet *)values;

- (NSDictionary*)encodeToJSON;

@end
