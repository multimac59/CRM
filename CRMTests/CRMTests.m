//
//  CRMTests.m
//  CRMTests
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppDelegate.h"
#import "NSDate+Additions.h"

@interface CRMTests : XCTestCase

@end

@implementation CRMTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testClosingVisits
{
    [[AppDelegate sharedDelegate]closeOldVisits];
    NSManagedObjectContext* context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Visit" inManagedObjectContext:context]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date<%@ AND closed==NO", [NSDate currentDate]];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *visits = [context executeFetchRequest:request error:&error];
    XCTAssertEqual(visits.count, (NSUInteger)0, @"Couldn't close all visits");
}

@end
