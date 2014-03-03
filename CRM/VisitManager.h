//
//  VisitPlanner.h
//  CRM
//
//  Created by FirstMac on 03.03.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisitManager : NSObject
+ (id)sharedManager;
- (Visit*)visitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date;
- (BOOL)toggleCommerceVisitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date;
- (BOOL)togglePromoVisitInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date;
- (BOOL)togglePharmacyCircleInPharmacy:(Pharmacy*)pharmacy forDate:(NSDate*)date;
@end