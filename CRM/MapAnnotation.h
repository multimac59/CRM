                    //
//  MapAnnotation.h
//  CRM
//
//  Created by FirstMac on 23.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YandexMapKit.h"
#import "Visit.h"
#import "PHarmacy.h"

@interface MapAnnotation : NSObject<YMKAnnotation>
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign) YMKMapCoordinate coordinate;
@property (nonatomic, assign) Visit* visit;
@property (nonatomic, assign) Pharmacy* pharmacy;
@end