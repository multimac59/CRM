//
//  Drug.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Drug : NSManagedObject

@property (nonatomic, retain) NSNumber * drugId;
@property (nonatomic, retain) NSString * name;

@end
