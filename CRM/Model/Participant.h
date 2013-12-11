//
//  Participant.h
//  
//
//  Created by FirstMac on 11.12.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Participant : NSManagedObject

@property (nonatomic, retain) NSNumber * participantId;
@property (nonatomic, retain) NSString * name;

@end
