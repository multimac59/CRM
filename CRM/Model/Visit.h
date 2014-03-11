//
//  Visit.h
//  CRM
//
//  Created by FirstMac on 21.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CommerceVisit, Pharmacy, PharmacyCircle, PromoVisit, User;

@interface Visit : NSManagedObject

@property (nonatomic, retain) NSNumber * closed;
@property (nonatomic, retain) NSNumber * sent;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * visitId;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) CommerceVisit *commerceVisit;
@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) PharmacyCircle *pharmacyCircle;
@property (nonatomic, retain) PromoVisit *promoVisit;
@property (nonatomic, retain) User *user;

- (NSDictionary*)encodeToJSON;

@end
