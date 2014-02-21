//
//  AppDelegate.h
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "MGCustomSplitViewController.h"
#import "SidePanelController.h"
#import "MFSideMenuCustomContainer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SidePanelDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MGCustomSplitViewController* visitsSplitController;
@property (strong, nonatomic) MGCustomSplitViewController* clientsSplitController;
@property (strong, nonatomic) MFSideMenuCustomContainer* container; //MGSplitViewController works incorrectly as root controller, so we pack it in this
@property (nonatomic, strong) SidePanelController* sidePanelController;
@property (nonatomic, strong) UIView* overlay;

@property (strong, nonatomic) User* currentUser;
@property (strong, nonatomic) NSArray* drugs;

+ (AppDelegate*)sharedDelegate;
- (void)saveContext;

@end
