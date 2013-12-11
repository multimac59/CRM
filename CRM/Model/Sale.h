//
//  Sale.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drug, Visit, User;
@interface Sale : NSManagedObject

@property (nonatomic, retain) NSNumber * saleId;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * remainder;
@property (nonatomic, retain) NSNumber * sold;
@property (nonatomic, retain) Drug *drug;
@property (nonatomic, retain) Visit *visit;
@property (nonatomic, retain) User *user;

@end
