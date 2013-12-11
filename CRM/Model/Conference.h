//
//  Conference.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Brand, Participant, Pharmacy, User;

@interface Conference : NSManagedObject

@property (nonatomic, retain) NSNumber * conferenceId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Pharmacy *pharmacy;
@property (nonatomic, retain) NSSet *participants;
@property (nonatomic, retain) NSSet *brands;
@end

@interface Conference (CoreDataGeneratedAccessors)

- (void)addParticipantsObject:(Participant *)value;
- (void)removeParticipantsObject:(Participant *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

- (void)addBrandsObject:(Brand *)value;
- (void)removeBrandsObject:(Brand *)value;
- (void)addBrands:(NSSet *)values;
- (void)removeBrands:(NSSet *)values;

@end
