//
//  Conference.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pharmacy.h"
#import "User.h"

@interface Conference : NSObject
@property (nonatomic) NSInteger conferenceId;
@property (nonatomic) User* user;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) Pharmacy* pharmacy;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSMutableArray* participants;
@property (nonatomic, strong) NSMutableArray* brands;
@end
