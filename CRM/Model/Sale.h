//
//  Sale.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CommerceVisit, Dose;

@interface Sale : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * remainder;
@property (nonatomic, retain) NSNumber * saleId;
@property (nonatomic, retain) NSNumber * sold;
@property (nonatomic, retain) CommerceVisit *commerceVisit;
@property (nonatomic, retain) Dose *dose;

@end
