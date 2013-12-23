//
//  KissXMLResponseSerializer.m
//  CRM
//
//  Created by FirstMac on 20.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "RaptureXMLResponseSerializer.h"
#import "RXMLElement.h"
#import <CoreLocation/CoreLocation.h>

@implementation RaptureXMLResponseSerializer
-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    
    //NSString* path = [[NSBundle mainBundle]pathForResource:@"simple" ofType:@"xml"];
    //data = [NSData dataWithContentsOfFile:path];
    
    RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
    NSMutableArray* positions = [NSMutableArray new];
    
    /* Not usable for us, we need all positions
    [rootXML iterate:@"GeoObjectCollection.featureMember.GeoObject.Point.pos" usingBlock: ^(RXMLElement *e) {
        NSLog(e.text);
        NSArray *stringArray = [e.text componentsSeparatedByString:@" "];
    }];*/
    
    //Get rid of fucking xml namespaces!
    [rootXML iterateWithRootXPath:@"//*[local-name() = 'pos']" usingBlock: ^(RXMLElement *positionElement) {
        NSLog(@"Position = %@", positionElement.text);
        NSArray *coordinates = [positionElement.text componentsSeparatedByString:@" "];
        NSString* longitude = coordinates[0];
        NSString* latitude = coordinates[1];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
        [positions addObject:location];
    }];
    return positions;
}
@end
