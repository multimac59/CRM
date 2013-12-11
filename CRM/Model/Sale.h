//
//  Sale.h
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drug.h"
#import "User.h"
@class Visit;

@interface Sale : NSObject
@property (nonatomic) NSInteger saleId;
@property (nonatomic, strong) Drug* drug;
@property (nonatomic, weak) Visit* visit;
@property (nonatomic, strong) User* user;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSInteger remainder;
@property (nonatomic) NSInteger sold;
@end
