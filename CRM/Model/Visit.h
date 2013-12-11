//
//  Visit.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pharmacy.h"
#import "Sale.h"
#import "User.h"

@interface Visit : NSObject
@property (nonatomic) NSInteger visitId;
@property (nonatomic) User* user;
@property (nonatomic, strong) Pharmacy* pharmacy;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSMutableArray* sales;
@end