//
//  NSString+MD5Extension.h
//  CRM
//
//  Created by FirstMac on 24.02.14.
//  Copyright (c) 2014 Nestline. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyExtensions)
- (NSString *)md5;
@end

@interface NSData (MyExtensions)
- (NSString*)md5;
@end
