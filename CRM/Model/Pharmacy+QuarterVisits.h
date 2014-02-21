//
//  Pharmacy+QuarterVisits.h
//  CRM
//
//  Created by FirstMac on 07.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import "Pharmacy.h"

@interface Pharmacy (QuarterVisits)
@property (nonatomic, readonly, strong) NSArray* visitsInCurrentQuarter;
@end
