//
//  User.h
//  CRM
//
//  Created by FirstMac on 11.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic) NSInteger userId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableArray* drugs;
@end
