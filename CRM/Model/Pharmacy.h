//
//  Pharmacy.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pharmacy : NSObject
@property (nonatomic) NSInteger pharmacyId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* network;
@property (nonatomic, strong) NSString* city;
@property (nonatomic, strong) NSString* street;
@property (nonatomic, strong) NSString* house;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* doctorName;

@property (nonatomic, strong) NSMutableArray* visits;

//.....
@end
