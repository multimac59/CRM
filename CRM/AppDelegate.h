//
//  AppDelegate.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController* visitsSplitController;
@property (strong, nonatomic) UISplitViewController* clientsSplitController;

@property (strong, nonatomic) User* currentUser;

+ (AppDelegate*)sharedDelegate;
- (void)saveContext;

@end
