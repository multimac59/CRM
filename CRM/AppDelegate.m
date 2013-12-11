//
//  AppDelegate.m
//  CRM
//
//  Created by FirstMac on 09.12.13.
//  Copyright (c) 2013 Nestline. All rights reserved.
//

#import "AppDelegate.h"
#import "MFSideMenuContainerViewController.h"
#import "VisitsViewController.h"
#import "VisitViewController.h"
#import "SidePanelController.h"
#import "ClientsViewController.h"
#import "PharmacyViewController.h"
#import "CustomSplitController.h"
#import "LoginViewController.h"

#import "Brand.h"
#import "Drug.h"
#import "Pharmacy.h"
#import "Visit.h"
#import "Conference.h"
#import "Sale.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static AppDelegate* sharedDelegate = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sharedDelegate = self;
    
    self.brands = [self parseBrands];
    self.drugs = [self parseDrugs];
    self.users = [self parseUsers];
    self.pharmacies = [self parsePharmacies];
    self.visits = [self parseVisits];
    self.conferences = [self parseConferences];
    self.currentUser = self.users[0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    _visitsSplitController = [[CustomSplitController alloc]init];
    self.visitsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:[VisitsViewController new]],[[UINavigationController alloc]initWithRootViewController:[VisitViewController new]]];
    _clientsSplitController = [[CustomSplitController alloc]init];
    self.clientsSplitController.viewControllers = @[[[UINavigationController alloc]initWithRootViewController:[ClientsViewController new]],[[UINavigationController alloc]initWithRootViewController:[PharmacyViewController new]]];

    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:self.visitsSplitController
                                                    leftMenuViewController:[SidePanelController new]
                                                    rightMenuViewController:nil];
    container.shadow.enabled = YES;
    container.menuSlideAnimationEnabled = NO;
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    [container presentViewController:[LoginViewController new] animated:NO completion:nil];
    return YES;
}

- (NSMutableArray*)parseBrands
{
    NSString* brandsFile = [[NSBundle mainBundle]pathForResource:@"Brands" ofType:@"json"];
    NSData* brandsData = [NSData dataWithContentsOfFile:brandsFile];
    NSArray* brandsJSON = [NSJSONSerialization JSONObjectWithData:brandsData options:kNilOptions error:nil];
    NSMutableArray* brands = [NSMutableArray new];
    [brandsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Brand* brand = [Brand new];
         brand.brandId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
         brand.name = [obj objectForKey:@"name"];
         [brands addObject:brand];
     }];
    return brands;
}

- (NSMutableArray*)parseDrugs
{
    NSString* drugsFile = [[NSBundle mainBundle]pathForResource:@"Drugs" ofType:@"json"];
    NSData* drugsData = [NSData dataWithContentsOfFile:drugsFile];
    NSArray* drugsJSON = [NSJSONSerialization JSONObjectWithData:drugsData options:kNilOptions error:nil];
    NSMutableArray* drugs = [NSMutableArray new];
    [drugsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Drug* drug = [Drug new];
         drug.drugId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
         drug.name = [obj objectForKey:@"name"];
         [drugs addObject:drug];
     }];
    return drugs;
}

- (NSMutableArray*)parsePharmacies
{
    NSString* pharmaciesFile = [[NSBundle mainBundle]pathForResource:@"Pharmacies" ofType:@"json"];
    NSData* pharmaciesData = [NSData dataWithContentsOfFile:pharmaciesFile];
    NSArray* pharmaciesJSON = [NSJSONSerialization JSONObjectWithData:pharmaciesData options:kNilOptions error:nil];
    NSMutableArray* pharmacies = [NSMutableArray new];
    [pharmaciesJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Pharmacy* pharmacy = [Pharmacy new];
         pharmacy.pharmacyId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
         pharmacy.name = [obj objectForKey:@"name"];
         pharmacy.network = [obj objectForKey:@"network"];
         pharmacy.city = [obj objectForKey:@"city"];
         pharmacy.street = [obj objectForKey:@"street"];
         pharmacy.house = [obj objectForKey:@"house"];
         pharmacy.phone = [obj objectForKey:@"phone"];
         pharmacy.doctorName = [obj objectForKey:@"doctorName"];
         pharmacy.visits = [NSMutableArray new];
         [pharmacies addObject:pharmacy];
     }];
    return pharmacies;
}

- (NSMutableArray*)parseVisits
{
    NSString* visitsFile = [[NSBundle mainBundle]pathForResource:@"Visits" ofType:@"json"];
    NSData* visitsData = [NSData dataWithContentsOfFile:visitsFile];
    NSArray* visitsJSON = [NSJSONSerialization JSONObjectWithData:visitsData options:kNilOptions error:nil];
    NSMutableArray* visits = [NSMutableArray new];
    [visitsJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Visit* visit = [Visit new];
         NSString* visitDateString = [obj objectForKey:@"date"];
         NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
         dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
         visit.date = [dateFormatter dateFromString:visitDateString];
         visit.visitId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
         NSInteger userId = ((NSNumber*)[obj objectForKey:@"userId"]).integerValue;
         visit.user = [self findUserById:userId];
         visit.sales = [NSMutableArray new];
         NSMutableArray* sales = [obj objectForKey:@"sales"];
         [sales enumerateObjectsUsingBlock:^(id saleObj, NSUInteger idx, BOOL *stop) {
             Sale* sale = [Sale new];
             sale.saleId = ((NSNumber*)[saleObj objectForKey:@"id"]).integerValue;
             NSInteger drugId = ((NSNumber*)[saleObj objectForKey:@"drug"]).integerValue;
             Drug* drug = [self findDrugById:drugId];
             sale.user = visit.user;
             sale.drug = drug;
             sale.order = ((NSNumber*)[saleObj objectForKey:@"order"]).integerValue;
             sale.sold = ((NSNumber*)[saleObj objectForKey:@"sold"]).integerValue;
             sale.remainder = ((NSNumber*)[saleObj objectForKey:@"remainder"]).integerValue;
             sale.visit = visit;
             [visit.sales addObject:sale];
         }];
         
         NSInteger pharmacyId = ((NSNumber*)[obj objectForKey:@"pharmacy"]).integerValue;
         Pharmacy* pharmacy = [self findPharmacyById:pharmacyId];
         visit.pharmacy = pharmacy;
         [pharmacy.visits addObject:visit];
         [visits addObject:visit];
     }];
    return visits;
}

- (NSMutableArray*)parseConferences
{
    NSString* conferencesFile = [[NSBundle mainBundle]pathForResource:@"Conferences" ofType:@"json"];
    NSData* conferencesData = [NSData dataWithContentsOfFile:conferencesFile];
    NSArray* conferencesJSON = [NSJSONSerialization JSONObjectWithData:conferencesData options:kNilOptions error:nil];
    NSMutableArray* conferences = [NSMutableArray new];
    [conferencesJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         Conference* conference = [Conference new];
         NSString* visitDateString = [obj objectForKey:@"date"];
         NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
         dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
         conference.date = [dateFormatter dateFromString:visitDateString];
         conference.conferenceId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
         NSInteger userId = ((NSNumber*)[obj objectForKey:@"userId"]).integerValue;
         conference.user = [self findUserById:userId];
         conference.name = [obj objectForKey:@"name"];
         conference.participants = [[obj objectForKey:@"participants"]mutableCopy];
         conference.brands = [NSMutableArray new];
         NSMutableArray* brandIds = [obj objectForKey:@"brands"];
         [brandIds enumerateObjectsUsingBlock:^(NSNumber* brandObj, NSUInteger idx, BOOL *stop) {
             NSInteger brandId = brandObj.integerValue;
             Brand* brand = [self findBrandById:brandId];
             [conference.brands addObject:brand];
         }];
         NSInteger pharmacyId = ((NSNumber*)[obj objectForKey:@"pharmacy"]).integerValue;
         Pharmacy* pharmacy = [self findPharmacyById:pharmacyId];
         conference.pharmacy = pharmacy;
         [conferences addObject:conference];
     }];
    return conferences;
}

- (NSMutableArray*)parseUsers
{
    NSString* usersFile = [[NSBundle mainBundle]pathForResource:@"Users" ofType:@"json"];
    NSData* usersData = [NSData dataWithContentsOfFile:usersFile];
    NSMutableArray* usersJSON = [NSJSONSerialization JSONObjectWithData:usersData options:kNilOptions error:nil];
    NSMutableArray* users = [NSMutableArray new];
    [usersJSON enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User* user = [User new];
        user.userId = ((NSNumber*)[obj objectForKey:@"id"]).integerValue;
        user.name = [obj objectForKey:@"name"];
        user.drugs = [NSMutableArray new];
        NSMutableArray* drugIds = [obj objectForKey:@"drugs"];
        [drugIds enumerateObjectsUsingBlock:^(NSNumber* drugObj, NSUInteger idx, BOOL *stop) {
            NSInteger drugId = drugObj.integerValue;
            Drug* drug = [self findDrugById:drugId];
            [user.drugs addObject:drug];
        }];
        [users addObject:user];
    }];
    return users;
}

- (Drug*)findDrugById:(NSInteger)drugId
{
    for (Drug* drug in self.drugs)
    {
        if (drug.drugId == drugId)
            return drug;
    }
    return nil;
}

- (Brand*)findBrandById:(NSInteger)brandId
{
    for (Brand* brand in self.brands)
    {
        if (brand.brandId == brandId)
            return brand;
    }
    return nil;
}

- (Pharmacy*)findPharmacyById:(NSInteger)pharmacyId
{
    for (Pharmacy* pharmacy in self.pharmacies)
    {
        if (pharmacy.pharmacyId == pharmacyId)
        {
            return pharmacy;
        }
    }
    return nil;
}

- (User*)findUserById:(NSInteger)userId
{
    for (User* user in self.users)
    {
        if (user.userId == userId)
        {
            return user;
        }
    }
    return nil;
}
				
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (id)sharedDelegate
{
    
    if (sharedDelegate == nil) {
        sharedDelegate = [[super allocWithZone:NULL] init];
    }
    return sharedDelegate;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CardioRiskModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CardioRiskModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


@end
