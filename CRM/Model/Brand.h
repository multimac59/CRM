//
//  Brand.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * brandId;

@end
