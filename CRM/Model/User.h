//
//  User.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drug;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *drugs;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addDrugsObject:(Drug *)value;
- (void)removeDrugsObject:(Drug *)value;
- (void)addDrugs:(NSSet *)values;
- (void)removeDrugs:(NSSet *)values;

@end
