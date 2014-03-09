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
#import "PharmaciesViewController.h"
#import "VisitsViewController.h"
#import "LoginViewController.h"

#define ARC4RANDOM_MAX 0x100000000
#define LOCAL 1
#define FULL_LOAD 0

@interface AppDelegate : UIResponder <UIApplicationDelegate, SidePanelDelegate>
{
    NSOperationQueue* bgQueue;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext2;
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

@property (strong, nonatomic) PharmaciesViewController* pharmaciesViewController;
@property (strong, nonatomic) VisitsViewController* visitsViewController;

@property (strong, nonatomic) LoginViewController* loginViewController;

+ (AppDelegate*)sharedDelegate;
- (void)saveContext;

- (User*)findUserById:(NSInteger)userId;
- (User*)findUserByLogin:(NSString*)login andPassword:(NSString*)password;
- (Region*)findRegionById:(NSInteger)regionId;

- (void)sendDataToServer;
- (void)showLoginScreenWithAnimation:(BOOL)animated;

- (void)loadDataFromServer;
- (void)reloadData;

- (void)closeOldVisits;

@end