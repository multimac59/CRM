                    //
//  MapAnnotation.h
//  CRM
//
//  Created by FirstMac on 23.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YandexMapKit.h"

@interface MapAnnotation : NSObject<YMKAnnotation>
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign) YMKMapCoordinate coordinate;
@end